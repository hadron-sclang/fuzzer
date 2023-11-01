#[macro_use]
extern crate afl;
extern crate hadron_sclang;

fn main() {
    fuzz!(|data: &[u8]| {
        let s = std::str::from_utf_unchecked(data);
        let _ = hadron_sclang::toolchain::lexer::tokenize(&s).count();
    });
}
