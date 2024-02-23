use std::io;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Image {
    pub rows: u32,
    pub cols: u32,
    pub image: Vec<Vec<Color>>,
}

impl Image {
    pub fn read(input: &str) -> Result<Self, nom::Err<nom::error::Error<String>>> {
        use nom::{
            bytes::complete::tag,
            character::complete::{multispace1, u32, u8},
            combinator::{flat_map, map},
            multi::many_m_n,
            sequence::{preceded, tuple},
            IResult,
        };
        fn color(input: &str) -> IResult<&str, Color> {
            map(
                tuple((
                    preceded(multispace1, u8),
                    preceded(multispace1, u8),
                    preceded(multispace1, u8),
                )),
                |(r, g, b)| Color { r, g, b },
            )(input)
        }
        fn size(input: &str) -> IResult<&str, (u32, u32)> {
            tuple((preceded(multispace1, u32), preceded(multispace1, u32)))(input)
        }
        fn image<'a>(
            r: usize,
            c: usize,
        ) -> impl FnMut(&'a str) -> IResult<&'a str, Vec<Vec<Color>>> {
            many_m_n(r, r, many_m_n(c, c, color))
        }
        match preceded(
            tag("P3"),
            flat_map(size, |(c, r)| {
                map(
                    preceded(
                        preceded(multispace1, tag("255")),
                        image(r as usize, c as usize),
                    ),
                    move |image| Image {
                        cols: c,
                        rows: r,
                        image,
                    },
                )
            }),
        )(input)
        {
            Ok((_, r)) => Ok(r),
            Err(e) => Err(e.to_owned()),
        }
    }
    pub fn write<W: io::Write>(&self, mut writer: W) -> io::Result<()> {
        writeln!(writer, "P3")?;
        writeln!(writer, "{} {}", self.cols, self.rows)?;
        writeln!(writer, "255")?;
        for r in &self.image {
            fn write_color<W: io::Write>(writer: &mut W, c: Color) -> io::Result<()> {
                write!(writer, "{:>3} {:>3} {:>3}", c.r, c.g, c.b)
            }
            write_color(&mut writer, r[0])?;
            for c in &r[1..] {
                write!(writer, "   ")?;
                write_color(&mut writer, *c)?;
            }
            writeln!(writer)?;
        }
        Ok(())
    }
}
