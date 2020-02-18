# 📄 `PDF` Links

**A convinient way to create / layout / maintain PDF link annotations in Adobe Illustrator.** 

## Motivation

While you can create automatic links in a PDF (by put the actual url into a textbox), it is limiting in various ways (create links on graphics, create custom hotspot). Also, when iterating on a document design, I found it pretty cumbersome to create / update link annotations in external apps, so after some research on [Apple PDFKit](https://developer.apple.com/documentation/pdfkit) I put together this tiny tool.


## Usage

Create a layer for the links (that you can hide later on).

<img src="Documentation/PDF_Links_1.png" width="640">

Create a text starting with **"Link "** followed by the actual url.

Wrap into a clipping rectangle to define link hotspot.

Hide layer containing the links before export PDF.

<img src="Documentation/PDF_Links_2.png" width="640">

Launch PDF Links, drag PDF into.

<img src="Documentation/PDF_Links_5.png" width="640">

Enjoy linked PDF.

<img src="Documentation/PDF_Links_7.png" width="640">


## Install

An installer is packaged at [`PDF_Links.dmg`](https://github.com/eppz/macOS.Production.PDF_Links/releases/download/Release_0.6.5/PDF_Links.dmg).


## Background

Besides the use case, this repository is a prototype for **PDF content processing in Swift**.

The pages, annotations, textual content is pretty accessable with the high-level [`PDFKit.PDFDocument`](https://developer.apple.com/documentation/pdfkit/pdfdocument) APIs. However, the actual content streams in a PDF (images / graphics) are only accessible as raw data via [`PDFKit.CGPDFDocument`](https://developer.apple.com/documentation/coregraphics/cgpdfdocument).

The project contains a [**`Parser.swift`**](https://github.com/eppz/macOS.Production.PDF_Links/blob/master/PDFLinks/Parser/Parser.swift) class that crawls a PDF object hierarchy and maps out the content as a `JSON` for further inspection. Using that JSON you can plan out various processing implementations (images / fonts / graphics / layers / metadata / etc.).

```Swift
// Parse PDF into JSON.
PDFParser.parse(pdfUrl: pdfFileURL, into: jsonFileURL)

// Parse PDF into Dictionary.
let pdf: [String:Any?] = PDFParser.parse(pdfUrl: pdfFileURL)
```

The resulting JSON gives you the entire PDF content (with type information in angle brackets). 

```
{
  "Catalog" : {
    "Pages<Dictionary>" : {
      "MediaBox<Array>" : [
        0,
        0,
        612,
        792
      ],
      "Type<Name>" : "Pages",
      "Kids<Array>" : [
        {
          "Rotate<Integer>" : 0,
          "MediaBox<Array>" : [
            0,
            0,
            595.27499999999998,
            841.88999999999999
          ],
          "Parent<Dictionary>" : "<PARENT_NOT_SERIALIZED>",
          "Resources<Dictionary>" : {
            "ColorSpace<Dictionary>" : {
              "Cs1<Array>" : [
                "ICCBased",
                {
                  "N<Integer>" : 3,
                  "Filter<Name>" : "FlateDecode",
                  "Alternate<Name>" : "DeviceRGB",
                  "Length<Integer>" : 2612
                }
              ]
            }
...
``` 

You can get the PDF content as a Swift dictionary as well (see console output below).

```
Optional(["Pages<Dictionary>": Optional({
    "Count<Integer>" = 1;
    "Kids<Array>" =     (
                {
            "ArtBox<Array>" =             (
                "28.3465",
                "325.193",
                "393.389",
                "813.543"
            );
            "Contents<Stream>" =             {
                Data = "q Q q 0 0 595.276 841.89 re W n 1 0 1 0 k /Gs1 gs 201.8862 420.9449 m 201.8862\n473.8269 244.7562 516.6959 297.6372 516.6959 c 350.5192 516.6959 393.3892\n473.8269 393.3892 420.9449 c 393.3892 368.0629 350.5192 325.1939 297.6372\n325.1939 c 244.7562 325.1939 201.8862 368.0629 201.8862 420.9449 c f Q q 28.346 530.078 283.464 283.465\nre W n 0 0 0 1 k /Gs1 gs BT 12 0 0 12 28.3467 803.499 Tm /Tc1 1 Tf [ (h) 4\n(ttp://epp) 7 (z.eu) ] TJ ET Q";
                "Filter<Name>" = FlateDecode;
                "Length<Integer>" = 237;
            };
            "MediaBox<Array>" =             (
                0,
                0,
                "595.2760000000001",
                "841.89"
            );
            "Parent<Dictionary>" = "<PARENT_NOT_SERIALIZED>";
            "Resources<Dictionary>" =             {
                "ExtGState<Dictionary>" =                 {
                    "Gs1<Dictionary>" =                     {
                        "OPM<Integer>" = 1;
                        "Type<Name>" = ExtGState;
                    };
                };
...
```

See [**`Parser.swift`**](https://github.com/eppz/macOS.Production.PDF_Links/blob/master/PDFLinks/Parser/Parser.swift) for more.

Graphics **data is serialized using COS** (Carousel Object System). Although Carousel was only a code name for what later became Acrobat, the name is still used to refer to the way a PDF file is composed. From the documentation: "...the data in a content stream is interpreted as a sequence of operators and their operands, expressed as basic data objects according to standard PDF syntax...". See official [**PDF Reference**](https://www.adobe.com/content/dam/acom/en/devnet/pdf/pdfs/pdf_reference_archives/PDFReference.pdf) for more.

Here is what a slice of the contents of the example PDF used in *Usage* section looks like.

```
...
/OC /MC1 BDC 
0.02 0.655 0.502 rg
0 586.77 595.275 255.119 re
f
EMC 
/OC /MC2 BDC 
BT
1 1 1 rg
/TT0 1 Tf
32.0407 0 0 32.0407 255.1182 714.3296 Tm
(Geri Borb\\341s)Tj
/TT1 1 Tf
14 0 0 14 255.1182 670.0706 Tm
[(I lo)19.1 (v)17.9 (e this industry)48 (. In the past 8 )28 (y)18 (ears I made )]TJ
0 -1.286 Td
[(numer)26 (ous )31 (Apps and Games )]TJ
/TT0 1 Tf
[(fr)26 (om z)14.1 (er)26 (o t)13 (o )]TJ
0 -1.286 Td
[(mark)27 (e)4 (t)]TJ
/TT1 1 Tf
[(, bo)7.1 (th t)13 (eamed and solo.)]TJ
ET
...
```

It is somewhat human readable, seemingly designed to direct draw using the operators. In this project I used the regex below to parse link text data with the bounds of the corresponding clipping rectangles. See the [**expression on Regex101**](https://regex101.com/r/jS8XMl/16) for more.

```Regex
# Clipping Rectangle (x, y, width, height)
(?<x>\b[-0-9.]+\b)\s
(?<y>\b[-0-9.]+\b)\s
(?<width>\b[-0-9.]+\b)\s
(?<height>\b[-0-9.]+\b)\s
re\nW

# Spacing
(?:
    .   # Any character
    (?! # Except followed by
        # Clipping Rectangle
        (\b[-\d.]+\b\s){4}
        re\nW
    )
)*? # 0 or more times

# URL
BT
    # Spacing
    (?:
        .      # Any character 
        (?!ET) # Except followed by 'ET'
    )*?        # 0 or more times
\n
    # Link
    (?<URL>
        .[^\n]*? # Any character except new-line 0 or more times
        Link     # Containing 'Link'
        .*?      # Any character 0 or more times
    )
    # Followed by 'TJ' or 'Tj' at the end of the line
    (?:TJ\n|Tj\n)
ET
```

It parses the graphic content into nicely usable Swift Codable structs. See [**`PageLinks.parseLinks(from contents:)`**](https://github.com/eppz/macOS.Production.PDF_Links/blob/master/PDFLinks/Links/PageLinks.swift#L80) for more. After parsing it can be encoded into JSON easily.

```
{
"pages" : [
  {
    "links" : [
      {
        "bounds" : {
          "y" : 43.936999999999998,
          "x" : 43.936999999999998,
          "width" : 39.685000000000002,
          "height" : 39.686
        },
        "urlString" : "http:\/\/bit.ly\/GeriBorbasLinkedIn"
      },
      {
        "bounds" : {
          "y" : 43.936999999999998,
          "x" : 86.456999999999994,
          "width" : 39.685000000000002,
          "height" : 39.686
        },
        "urlString" : "http:\/\/bit.ly\/GeriBorbasTwitter"
      },
      {
        "bounds" : {
          "y" : 43.936999999999998,
          "x" : 128.976,
          "width" : 39.685000000000002,
          "height" : 39.686
        },
        "urlString" : "http:\/\/bit.ly\/GeriBorbasGitHub"
      },
...
```

To create `PDFKit.PDFAnnotation`, the same coordinate system can be used. Having that, a parsed `Link` can be directly converted into a `PDFKit.PDFAnnotation`. Those can be added to a PDF page easily with `PDFKit.PDFPage.addAnnotation(_:)`.

```Swift
extension Link
{


    var annotation: PDFAnnotation
    {
        PDFAnnotation(
            bounds: CGRect(x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height),
            forType: PDFAnnotationSubtype.link,
            withProperties: nil
        ).with(url: url)
    }
}
```


## License

> Licensed under the [**MIT License**](https://en.wikipedia.org/wiki/MIT_License).
