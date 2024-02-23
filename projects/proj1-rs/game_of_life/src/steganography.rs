use crate::image::{Color, Image};

const WHITE: Color = Color {
    r: 0xff,
    g: 0xff,
    b: 0xff,
};

const BLACK: Color = Color { r: 0, g: 0, b: 0 };

fn eval_pixel(color: Color) -> Color {
    if color.b & 1 == 1 {
        WHITE
    } else {
        BLACK
    }
}

pub fn steganography(i: &Image) -> Image {
    Image {
        rows: i.rows,
        cols: i.cols,
        image: i
            .image
            .iter()
            .map(|r| r.iter().copied().map(eval_pixel).collect())
            .collect(),
    }
}

#[cfg(test)]
mod tests {
    use crate::image::{Color, Image};

    use super::{steganography, BLACK, WHITE};

    #[test]
    fn sample() {
        assert_eq!(
            steganography(&Image {
                rows: 2,
                cols: 2,
                image: Vec::from([
                    Vec::from([
                        Color {
                            r: 29,
                            g: 83,
                            b: 36
                        },
                        Color {
                            r: 45,
                            g: 64,
                            b: 57
                        }
                    ]),
                    Vec::from([
                        Color {
                            r: 188,
                            g: 229,
                            b: 201
                        },
                        Color {
                            r: 123,
                            g: 162,
                            b: 184
                        }
                    ])
                ])
            }),
            Image {
                rows: 2,
                cols: 2,
                image: Vec::from([Vec::from([BLACK, WHITE]), Vec::from([WHITE, BLACK])])
            }
        );
    }
}
