// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

use adblock::url_parser::ResolvesDomain;
use publicsuffix::List;

pub struct DomainResolver {
    suffix_list: List,
}

impl DomainResolver {
    pub fn new(path: &str) -> Option<DomainResolver> {
        if let Ok(list) = List::from_path(path) {
            Some(DomainResolver { suffix_list: list })
        } else {
            None
        }
    }
}

impl ResolvesDomain for DomainResolver {
    fn get_host_domain(&self, host: &str) -> (usize, usize) {
        if host.is_empty() {
            return (0, 0);
        }

        if let Ok(domain) = self.suffix_list.parse_domain(host) {
            if let Some(root) = domain.root() {
                let host_len = host.len();
                let domain_start = host_len - root.len();

                assert_eq!(&host[domain_start..host_len], root);
                return (domain_start, host_len);
            }
        }

        (0, host.len())
    }
}
