// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

use std::fs;
use std::fs::read_to_string;

use adblock::engine::Engine;
use adblock::lists::{FilterFormat, FilterSet};

use crate::adblock_debug;
use crate::domainresolver::DomainResolver;

struct Adblock {
    blocker: Option<Engine>,
}

/// creates a new adblock object, and returns a pointer to it.
/// If the passed list_dir is invalid, the Adblock will not contain an engine.
fn new_adblock(list_dir: &str, suffix_file: &str) -> Box<Adblock> {
    adblock_debug!("## Creating new adblock instance");
    // Create domain resolver
    if let Some(domain_resolver) = DomainResolver::new(suffix_file) {
        // and wire it up
        // https://docs.rs/once_cell/1.5.2/once_cell/sync/struct.OnceCell.html#method.set
        // Unfortunately the once_cell can only be set once, which means we have no way to reload
        // the public suffix list.
        match ::adblock::url_parser::set_domain_resolver(Box::new(domain_resolver)) {
            Ok(()) => adblock_debug!("resolver set for the first time"),
            Err(_resolver) => adblock_debug!("resolver already set, can't replace"),
        }

        let mut filter_set = FilterSet::new(true);

        // iterate directory
        if let Ok(entries) = fs::read_dir(list_dir) {
            for entry in entries {
                if let Ok(e) = entry {
                    if let Ok(ft) = e.file_type() {
                        if ft.is_file() {
                            adblock_debug!("Loading filter {:?}", e);
                            let contents = read_to_string(e.path().as_path()).unwrap();
                            filter_set.add_filter_list(&contents, FilterFormat::Standard);
                        }
                    }
                }
            }

            let blocker = Engine::from_filter_set(filter_set, true);
            return Box::new(Adblock {
                blocker: Some(blocker),
            });
        }
    }
    Box::new(Adblock { blocker: None })
}

impl Adblock {
    /// returns a boxed AdblockResult object with information on whether
    /// the request should be blocked or redirected.
    fn should_block(&self, url: &str, source_url: &str, request_type: &str) -> ffi::AdblockResult {
        if let Some(engine) = &self.blocker {
            let blocker_result = engine.check_network_urls(url, source_url, request_type);
            adblock_debug!("Blocker input: {}, {}, {}", url, source_url, request_type);
            adblock_debug!("Blocker result: {:?}", blocker_result);

            return ffi::AdblockResult {
                matched: blocker_result.matched,
                important: blocker_result.important,
                redirect: blocker_result.redirect.unwrap_or_default(),
            };
        }

        ffi::AdblockResult::default()
    }
}

#[cxx::bridge]
mod ffi {
    #[derive(Default)]
    struct AdblockResult {
        matched: bool,
        important: bool,
        redirect: String,
    }

    extern "Rust" {
        type Adblock;

        fn new_adblock(list_dir: &str, suffix_file: &str) -> Box<Adblock>;
        fn should_block(
            self: &Adblock,
            url: &str,
            source_url: &str,
            request_type: &str,
        ) -> AdblockResult;
    }
}
