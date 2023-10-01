#[macro_use]
extern crate afl;
extern crate hadron_sclang;

fn main() {
    fuzz!(|data: &[u8]| {
        if let Ok(s) = std::str::from_utf8(data) {
            let _ = hadron_sclang::toolchain::lexer::tokenize(&s).count();
        }
    });
}
