use std::io;

use image::{
    codecs::gif::{self, GifEncoder},
    Delay, Frame, ImageResult, RgbaImage,
};

pub mod game;

pub fn write_gif<W: io::Write, I: IntoIterator<Item = RgbaImage>>(
    writer: W,
    it: I,
) -> ImageResult<()> {
    let mut enc = GifEncoder::new(writer);
    enc.set_repeat(gif::Repeat::Finite(0))?;
    enc.encode_frames(
        it.into_iter()
            .map(|f| Frame::from_parts(f, 0, 0, Delay::from_numer_denom_ms(20, 1))),
    )
}
