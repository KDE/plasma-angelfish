use std::os::raw::c_char;
use std::ffi::CString;

use std::mem::drop;

extern "C" {
    fn q_cdebug_adblock(message: *const c_char);
}

pub fn adblock_debug(message: String) {
    if let Ok(cstring) = CString::new(message) {
        unsafe {
            let ptr = cstring.into_raw();
            q_cdebug_adblock(ptr);
            drop(CString::from_raw(ptr));
        };
    }
}

#[macro_export]
macro_rules! adblock_debug {
    ($($arg:tt)*) => ({
        $crate::logging::adblock_debug(format!($($arg)*));
    })
}
