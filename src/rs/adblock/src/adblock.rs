// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

use adblock::engine::Engine;
use adblock::lists::{FilterFormat, FilterSet};
use std::ffi::{CStr, CString};
use std::mem::drop;
use std::os::raw::c_char;
use std::ptr;

use std::fs::read_to_string;
use std::fs::{self};

use crate::adblock_debug;
use crate::domainresolver::DomainResolver;

#[repr(C)]
pub struct Adblock {
    blocker: *mut Engine,
}

#[repr(C)]
pub struct AdblockResult {
    pub matched: bool,
    pub important: bool,
    pub redirect: Option<*mut c_char>,
}

/// Deletes an AdblockResult object
#[no_mangle]
pub unsafe extern "C" fn free_adblock_result(result: *mut AdblockResult) {
    // Don't try to free nullptr
    if !result.is_null() {
        let boxed_adblock_result = Box::from_raw(result);
        if let Some(r) = boxed_adblock_result.redirect {
            drop(CString::from_raw(r));
        }
        drop(boxed_adblock_result);
    }
}

/// creates a new adblock object, and returns a pointer to it.
/// If the passed list_dir is invalid, returns a nullptr.
#[no_mangle]
pub extern "C" fn new_adblock(
    list_dir: *const c_char,
    public_domain_suffix_file: *const c_char,
) -> *mut Adblock {
    adblock_debug!("## Creating new adblock instance");

    if let Ok(suffix_file) = unsafe { CStr::from_ptr(public_domain_suffix_file) }.to_str() {
        // Create domain resolver
        if let Some(domain_resolver) = DomainResolver::new(suffix_file) {
            // and wire it up
            // https://docs.rs/once_cell/1.5.2/once_cell/sync/struct.OnceCell.html#method.set
            // Unfortunately the once_cell can only be set once, which means we have no way to reload
            // the public suffix list.
            match adblock::url_parser::set_domain_resolver(Box::new(domain_resolver)) {
                Ok(()) => adblock_debug!("resolver set for the first time"),
                Err(_resolver) => adblock_debug!("resolver already set, can't replace"),
            }

            // Try to decode dir path
            if let Ok(path) = unsafe { CStr::from_ptr(list_dir) }.to_str() {
                let mut filter_set = FilterSet::new(true);

                // iterate directory
                let dir_entries = fs::read_dir(path);

                if let Ok(entries) = dir_entries {
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
                    return Box::into_raw(Box::new(Adblock {
                        blocker: Box::into_raw(Box::new(blocker)),
                    }));
                }
            }
        }
    }

    ptr::null_mut()
}

/// Deletes the adblock object
#[no_mangle]
pub unsafe extern "C" fn free_adblock(adblock: *mut Adblock) {
    // Don't try to free nullptr
    if !adblock.is_null() {
        let boxed_adblock = Box::from_raw(adblock);
        drop(Box::from_raw(boxed_adblock.blocker));
        drop(boxed_adblock);
    }
}

/// returns an AdblockResult object with information on whether
/// the request should be blocked or redirected.
/// Ownership of the object is passed to the called, and they are
/// responsible for calling free_adblock_result on it.
#[no_mangle]
pub unsafe extern "C" fn should_block(
    adblock: *mut Adblock,
    url: *const c_char,
    source_url: *const c_char,
    request_type: *const c_char,
) -> *mut AdblockResult {
    // extract rust types from c arguments
    let url = CStr::from_ptr(url).to_str().unwrap_or_default();
    let source_url = CStr::from_ptr(source_url).to_str().unwrap_or_default();
    let request_type = CStr::from_ptr(request_type).to_str().unwrap_or_default();

    assert!(!adblock.is_null(), "you are using it wrong");
    assert!(!(*adblock).blocker.is_null());
    let blocker = &*(*adblock).blocker;

    let blocker_result = blocker.check_network_urls(url, source_url, request_type);
    adblock_debug!("Blocker input: {}, {}, {}", url, source_url, request_type);
    adblock_debug!("Blocker result: {:?}", blocker_result);

    let redirectc: Option<*mut c_char> = match blocker_result.redirect {
        Some(redirect) => match CString::new(redirect) {
            Ok(r) => Some(r.into_raw()),
            Err(_) => None,
        },
        None => None,
    };

    Box::into_raw(Box::from(AdblockResult {
        matched: blocker_result.matched,
        important: blocker_result.important,
        redirect: redirectc,
    }))
}
