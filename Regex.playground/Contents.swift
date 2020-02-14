import UIKit
import Foundation


// MARK: - Extensions

extension String
{
    
    var entireRange: NSRange
    { NSRange(location: 0, length: self.utf16.count) }
    
    func substring(with range: NSRange) -> String
    {
        let rangeStartIndex = self.index(self.startIndex, offsetBy: range.location)
        let rangeEndIndex = self.index(rangeStartIndex, offsetBy: range.length)
        let indexRange = rangeStartIndex..<rangeEndIndex
        return String(self[indexRange])
    }
    
    func write(to fileName: String) throws
    {
        guard let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        try self.write(
            to: documentsFolder.appendingPathComponent(fileName),
            atomically: false,
            encoding: .utf8
        )
        print("`\(self.prefix(20))...` written to \(documentsFolder.appendingPathComponent(fileName)).")
    }
}


// MARK: - Strings

struct Constants
{
    
    
    static let originalHtmlFileName = "Original.html"
    static let replacedHtmlFileName = "Replaced.html"
    
    static let bodyTemplate = "%BODY%"
    
    static let htmlTemplate = """
    <html>
    <head>
    <style type="text/css">
    body { color: LightGray; }
    .match { color: black; background-color: PaleTurquoise; }
    .group { color: black; border-top: 1px solid black; border-right: 2px solid black; }
    .group._9, .group._19 { background: #66afe3; }
    .group._8, .group._18 { background: #66c0ec; }
    .group._7, .group._17 { background: #66d2f6; }
    .group._6, .group._16 { background: #66e1fd; }
    .group._5, .group._15 { background: #66ebff; }
    .group._4, .group._14 { background: #66f2e7; }
    .group._3, .group._13 { background: #66e5c2; }
    .group._2, .group._12 { background: #66daa6; }
    .group._1, .group._11 { background: #66d28c; }
    .group._10 { background: LightGray; }
    </style>
    </head>
    <body>
    <pre>
    \(Constants.bodyTemplate)
    </pre>
    </body>
    </html>
    """
    
    // See https://developer.apple.com/documentation/foundation/nsregularexpression#1965591
    static let replacementTemplate =
        "<span class=\"group _1\">$1</span>" +
        "<span class=\"group _2\">$2</span>" +
        "<span class=\"group _3\">$3</span>" +
        "<span class=\"group _4\">$4</span>" +
        "<span class=\"group _5\">$5</span>" +
        "<span class=\"group _6\">$6</span>" +
        "<span class=\"group _7\">$7</span>" +
        "<span class=\"group _8\">$8</span>" +
        "<span class=\"group _9\">$9</span>" +
        "<span class=\"group _10\">$10</span>" +
        "<span class=\"group _11\">$11</span>" +
        "<span class=\"group _12\">$12</span>" +
        "<span class=\"group _13\">$13</span>" +
        "<span class=\"group _14\">$14</span>" +
        "<span class=\"group _15\">$15</span>" +
        "<span class=\"group _16\">$16</span>" +
        "<span class=\"group _17\">$17</span>" +
        "<span class=\"group _18\">$18</span>"
}


// MARK: - Implementation

// Extract link texts with clipping rectangles.
let pattern_readable =
    """
    # Clipping Rectangle (x, y, width, height)
    (?<x>\\b[-0-9.]+\\b)\\s
    (?<y>\\b[-0-9.]+\\b)\\s
    (?<width>\\b[-0-9.]+\\b)\\s
    (?<height>\\b[-0-9.]+\\b)\\s
    re\\nW

    # Spacing
    (?:
        .   # Any character
        (?! # Except followed by
            # Clipping Rectangle
            (\\b[-\\d.]+\\b\\s){4}
            re\\nW
        )
    )*? # 0 or more times

    # Link
    BT
        # Spacing
        (?:
            .      # Any character
            (?!ET) # Except followed by 'ET'
        )*?        # 0 or more times
    \\n
        # Link
        (?<link>
            .[^\\n]*? # Any character except new-line 0 or more times
            Link     # Containing 'Link'
            .*?      # Any character 0 or more times
        )
        # Followed by 'TJ' or 'Tj' at the end of the line
        (?:TJ\\n|Tj\\n)
    ET
    """

let pattern = "(\\b[-0-9\\.]+\\b)(\\s)(\\b[-0-9\\.]+\\b)(\\s)(\\b[-0-9\\.]+\\b)(\\s)(\\b[-0-9\\.]+\\b)(\\s)(re\\nW)(.*?)(BT)(.*?)(Link)(.*?\\n)(.[^\\n]*?)(TJ\\n|Tj\\n)(ET)"

let regex = try NSRegularExpression(
    pattern: pattern_readable,
    options: [
        .dotMatchesLineSeparators,
        .allowCommentsAndWhitespace
    ])

// PDF Contents.
let contents = "/OC /MC0 BDC \n0.729 0.737 0.741 rg\n/GS0 gs\n269.292 107.572 -226.771 339.31 re\nf\n283.465 107.572 184.25 339.31 re\nf\n0.502 0.502 0.506 rg\n0 586.77 595.275 255.119 re\nf\n0.502 0.502 0.502 rg\n552.756 586.771 -297.638 18 re\nf\n0.427 0.431 0.443 rg\n552.756 604.771 -297.638 18 re\nf\n0.502 0.502 0.502 rg\n552.756 622.771 -297.638 18 re\nf\n0.565 0.573 0.584 rg\n552.755 465.731 -510.235 18 re\nf\n0.647 0.655 0.663 rg\n552.755 526.25 -510.235 18 re\nf\n552.755 508.25 -510.235 18 re\nf\n552.755 490.25 -510.235 18 re\nf\n0.502 0.502 0.502 rg\n333.818 647.291 -30.224 18 re\nf\n255.118 665.291 -6.52 6.52 re\nf\n255.118 640.771 -6.52 6.52 re\nf\nEMC \n/OC /MC1 BDC \n0.02 0.655 0.502 rg\n0 586.77 595.275 255.119 re\nf\nEMC \n/OC /MC2 BDC \nBT\n1 1 1 rg\n/TT0 1 Tf\n32.0407 0 0 32.0407 255.1182 714.3296 Tm\n(Geri Borb\\341s)Tj\n/TT1 1 Tf\n14 0 0 14 255.1182 670.0706 Tm\n[(I lo)19.1 (v)17.9 (e this industry)48 (. In the past 8 )28 (y)18 (ears I made )]TJ\n0 -1.286 Td\n[(numer)26 (ous )31 (Apps and Games )]TJ\n/TT0 1 Tf\n[(fr)26 (om z)14.1 (er)26 (o t)13 (o )]TJ\n0 -1.286 Td\n[(mark)27 (e)4 (t)]TJ\n/TT1 1 Tf\n[(, bo)7.1 (th t)13 (eamed and solo.)]TJ\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm0 Do\nQ\nQ\nBT\n0.137 0.122 0.125 rg\n/TT0 1 Tf\n14 0 0 14 42.52 531.0305 Tm\n[(H)7 (ello ther)26 (e, thanks f)26 (or)24 ( r)26 (eading this!)]TJ\n/TT1 1 Tf\n( )Tj\n/T1_0 1 Tf\n(         )Tj\n/TT1 1 Tf\n[(Be)5 (f)26 (or)25.9 (e dig deeper)45.9 (, I r)26 (ec)5 (ommend )28 (y)18 (ou )]TJ\n/C2_0 1 Tf\n0 -1.286 Td\n[<0058>13 <0053000300460056004D0049>5 <01F1>11 <005D>27 <00030057004F004D005100030058004C0056>26 <00530059004B004C00030058004C0049000300540056>26 <0053004E004900470058000300540045004B004900570003000D00180012>21 <00160015>18 <000E001100030058004C0049005200030047>5 <0053005100490003004600450047004F00030058>13 <005300030058004C004900030056>26 <00490057005800030053>8 <004A>21 <0003>]TJ\n/TT1 1 Tf\n0 -1.286 Td\n[(the r)26 (eadings a)4 (ft)13 (er)46 (.)]TJ\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm1 Do\nQ\nQ\nBT\n0.02 0.655 0.502 rg\n/TT0 1 Tf\n14 0 0 14 113.3862 429.8735 Tm\n[(epp)14 (z! mobile)]TJ\n/TT2 1 Tf\n(, SP)Tj\n0 0 0 rg\n/TT3 1 Tf\n12 0 0 12 113.3862 415.4734 Tm\n[(Apps and Games Pr)12 (oduction)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 -1.2 Td\n(Budapest, Hungary)Tj\n0 0 0 rg\n/TT0 1 Tf\n-0.028 Tw 14 0 0 14 485.8848 422.7869 Tm\n[(4 y)18 (ears)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 8 0 0 8 475.717 413.1868 Tm\n[(Dec 2011 - Pr)26 (esen)5 (t)]TJ\n0 0 0 rg\n/TT0 1 Tf\n-0.028 Tw 14 0 0 14 485.8848 351.9207 Tm\n[(4 y)18 (ears)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 8 0 0 8 473.853 342.3206 Tm\n[(Dec 2011 - )27 (Jun 2015)]TJ\n0 0 0 rg\n/TT0 1 Tf\n-0.028 Tw 14 0 0 14 485.8848 281.0549 Tm\n[(4 y)18 (ears)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 8 0 0 8 472.425 271.4548 Tm\n[(Sep 200)25 (7 - Dec 2011)]TJ\n0 0 0 rg\n/TT0 1 Tf\n-0.028 Tw 14 0 0 14 485.6328 210.1887 Tm\n[(6 y)18 (ears)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 8 0 0 8 471.3491 200.5886 Tm\n[(Sep 2000 - )27.1 (Jun 2006)]TJ\n0 0 0 rg\n/TT0 1 Tf\n-0.028 Tw 14 0 0 14 486.0039 139.3225 Tm\n[(5 y)18 (ears)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 8 0 0 8 472.2051 129.7224 Tm\n[(Sep 1995 - )27 (Jun 2000)]TJ\n0.02 0.655 0.502 rg\n/TT0 1 Tf\n14 0 0 14 113.3862 359.0073 Tm\n(POSSIBLE)Tj\n/TT2 1 Tf\n( CEE)Tj\n0 0 0 rg\n/TT3 1 Tf\n-0.031 Tw 12 0 0 12 113.3862 344.6072 Tm\n[(Digital)30.1 ( )-31.1 (Cr)11.9 (ea)4 (tiv)18 (e A)15 (genc)9 (y)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 0 -1.2 Td\n(Budapest, Hungary)Tj\n0.02 0.655 0.502 rg\n/TT0 1 Tf\n14 0 0 14 113.3862 288.1414 Tm\n[(M)7 (erlin)]TJ\n/TT2 1 Tf\n[( Communica)4 (tions)]TJ\n0 0 0 rg\n/TT3 1 Tf\n-0.031 Tw 12 0 0 12 113.3862 273.7412 Tm\n[(M)5 (ark)27 (e)5 (ting A)15.1 (genc)9 (y)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 0 -1.2 Td\n(Budapest, Hungary)Tj\n/TT0 1 Tf\n14 0 0 14 113.3862 217.2751 Tm\n[(Univ)18 (ersity)27.1 ( o)8 (f)21 ( P)9 (\\351cs)]TJ\n0 0 0 rg\n/TT3 1 Tf\n-0.031 Tw 12 0 0 12 113.3862 202.875 Tm\n[(F)57 (aculty)27.1 ( )-31.1 (o)9 (f)22 ( Arts)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 0 -1.2 Td\n[(P)9 (\\351cs, Hungary)]TJ\n/TT0 1 Tf\n14 0 0 14 113.3862 146.4089 Tm\n[(Zich)14 (y)27 ( Mih\\341l)11 (y)]TJ\n0 0 0 rg\n/TT3 1 Tf\n-0.031 Tw 12 0 0 12 113.3862 132.0088 Tm\n[(High )-31 (School)30 ( )-31 (o)9 (f)22 ( Applied Arts)]TJ\n0.502 0.502 0.506 rg\n/TT2 1 Tf\n0 Tw 0 -1.2 Td\n[(Kapos)10 (v)13 (\\341r)46 (, Hungary)]TJ\nET\nq\n283.702 529.047 18.598 18.599 re\nW n\nq\n18.5986805 0 0 18.5986805 283.7011955 529.0469136 cm\n/Im0 Do\nQ\nEMC \n/OC /MC3 BDC \nQ\nq\n0 841.89 595.275 -841.89 re\nW n\n0.137 0.122 0.125 rg\nq 1 0 0 1 489.27 692.6459 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.835 -2.835 c\n-64.556 -2.835 l\n-66.115 -2.835 -67.391 -1.56 -67.391 0 c\n-67.391 12.331 l\n-67.391 13.89 -66.115 15.165 -64.556 15.165 c\n-2.835 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 333.8179 692.6459 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-39.973 -2.835 l\n-41.532 -2.835 -42.807 -1.56 -42.807 0 c\n-42.807 12.331 l\n-42.807 13.89 -41.532 15.165 -39.973 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 285.3418 692.6459 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-27.389 -2.835 l\n-28.948 -2.835 -30.224 -1.56 -30.224 0 c\n-30.224 12.331 l\n-30.224 13.89 -28.948 15.165 -27.389 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 416.2104 692.6459 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-73.889 -2.835 l\n-75.448 -2.835 -76.724 -1.56 -76.724 0 c\n-76.724 12.331 l\n-76.724 13.89 -75.448 15.165 -73.889 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nQ\nBT\n0.02 0.655 0.502 rg\n/TT0 1 Tf\n14 0 0 14 294.6953 693.906 Tm\n(Unity)Tj\n-2.564 0 Td\n(iOS)Tj\n0.012 0.502 0.471 rg\n6.026 0 Td\n[(De)14 (v)18 (eloper)24 (  )]TJ\n5.895 0 Td\n(Designer)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\n0.02 0.655 0.502 rg\nq 1 0 0 1 350.856 408.0473 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-64.556 -2.835 l\n-66.115 -2.835 -67.391 -1.56 -67.391 0 c\n-67.391 12.331 l\n-67.391 13.89 -66.115 15.165 -64.556 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 362.166 431.7163 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-39.973 -2.835 l\n-41.532 -2.835 -42.807 -1.56 -42.807 0 c\n-42.807 12.331 l\n-42.807 13.89 -41.532 15.165 -39.973 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 313.688 431.7163 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-27.389 -2.835 l\n-28.948 -2.835 -30.223 -1.56 -30.223 0 c\n-30.223 12.331 l\n-30.223 13.89 -28.948 15.165 -27.389 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 444.5581 431.7163 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-73.889 -2.835 l\n-75.448 -2.835 -76.724 -1.56 -76.724 0 c\n-76.724 12.331 l\n-76.724 13.89 -75.448 15.165 -73.889 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nQ\nBT\n1 1 1 rg\n14 0 0 14 323.0425 432.9763 Tm\n(Unity)Tj\n-2.564 0 Td\n(iOS)Tj\n6.026 0 Td\n[(De)14 (v)18 (eloper)24 (  )]TJ\n-6.016 -1.691 Td\n(Designer)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\n0.02 0.655 0.502 rg\nq 1 0 0 1 350.856 337.1811 cm\n0 0 m\n0 -1.561 -1.275 -2.835 -2.834 -2.835 c\n-64.556 -2.835 l\n-66.115 -2.835 -67.391 -1.561 -67.391 0 c\n-67.391 12.331 l\n-67.391 13.89 -66.115 15.165 -64.556 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 362.165 360.8506 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-39.973 -2.835 l\n-41.532 -2.835 -42.807 -1.56 -42.807 0 c\n-42.807 12.331 l\n-42.807 13.889 -41.532 15.165 -39.973 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.889 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 313.688 360.8506 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-27.389 -2.835 l\n-28.948 -2.835 -30.223 -1.56 -30.223 0 c\n-30.223 12.331 l\n-30.223 13.889 -28.948 15.165 -27.389 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.889 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 444.5581 360.8506 cm\n0 0 m\n0 -1.56 -1.275 -2.835 -2.834 -2.835 c\n-73.889 -2.835 l\n-75.448 -2.835 -76.724 -1.56 -76.724 0 c\n-76.724 12.331 l\n-76.724 13.889 -75.448 15.165 -73.889 15.165 c\n-2.834 15.165 l\n-1.275 15.165 0 13.889 0 12.331 c\nh\nf\nQ\nQ\nBT\n14 0 0 14 323.0425 362.1106 Tm\n(Unity)Tj\n3.463 0 Td\n[(De)14 (v)18 (eloper)24 (  )]TJ\n-6.016 -1.691 Td\n(Designer)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\n0.02 0.655 0.502 rg\nq 1 0 0 1 350.856 266.3149 cm\n0 0 m\n0 -1.56 -1.275 -2.836 -2.834 -2.836 c\n-64.556 -2.836 l\n-66.115 -2.836 -67.391 -1.56 -67.391 0 c\n-67.391 12.331 l\n-67.391 13.89 -66.115 15.164 -64.556 15.164 c\n-2.834 15.164 l\n-1.275 15.164 0 13.89 0 12.331 c\nh\nf\nQ\nq 1 0 0 1 321.9399 289.8364 cm\n0 0 m\n0 -1.478 -1.209 -2.688 -2.688 -2.688 c\n-35.787 -2.688 l\n-37.265 -2.688 -38.474 -1.478 -38.474 0 c\n-38.474 12.625 l\n-38.474 14.103 -37.265 15.313 -35.787 15.313 c\n-2.688 15.313 l\n-1.209 15.313 0 14.103 0 12.625 c\nh\nf\nQ\nq 1 0 0 1 404.332 289.9834 cm\n0 0 m\n0 -1.559 -1.275 -2.834 -2.834 -2.834 c\n-73.889 -2.834 l\n-75.448 -2.834 -76.723 -1.559 -76.723 0 c\n-76.723 12.332 l\n-76.723 13.89 -75.448 15.166 -73.889 15.166 c\n-2.834 15.166 l\n-1.275 15.166 0 13.89 0 12.332 c\nh\nf\nQ\nQ\nBT\n-0.064 Tc 0.064 Tw 14 0 0 14 287.1504 291.2432 Tm\n[(We)-64 (b)]TJ\n0 Tc 0 Tw -0 5.062 Td\n(iOS)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm2 Do\nQ\nQ\nBT\n14 0 0 14 360.2103 267.8787 Tm\n(2D)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm3 Do\nQ\nQ\nBT\n14 0 0 14 391.4868 267.8787 Tm\n(3D)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm4 Do\nQ\nQ\nBT\n14 0 0 14 362.0101 338.4412 Tm\n(UI)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm5 Do\nQ\nQ\nBT\n14 0 0 14 413.8826 291.2439 Tm\n(UID)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm6 Do\nQ\nQ\nBT\n14 0 0 14 391.4661 338.4412 Tm\n(UX)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm7 Do\nQ\nQ\nBT\n14 0 0 14 424.1466 338.4412 Tm\n(R&D)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm8 Do\nQ\nQ\nBT\n14 0 0 14 362.0101 409.3074 Tm\n(UI)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm9 Do\nQ\nQ\nBT\n14 0 0 14 391.4666 409.3074 Tm\n(UX)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm10 Do\nQ\nQ\nBT\n14 0 0 14 424.4387 409.3074 Tm\n(AR)Tj\n-6.653 -8.433 Td\n[(De)14 (v)18 (eloper)24 (  )]TJ\n-3.143 -1.691 Td\n(Designer)Tj\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm11 Do\nQ\n0.647 0.655 0.663 rg\nq 1 0 0 1 441.6255 221.7314 cm\n0 0 m\n0 -2.997 -2.452 -5.449 -5.449 -5.449 c\n-152.711 -5.449 l\n-155.708 -5.449 -158.16 -2.997 -158.16 0 c\n-158.16 7.103 l\n-158.16 10.099 -155.708 12.551 -152.711 12.551 c\n-5.449 12.551 l\n-2.452 12.551 0 10.099 0 7.103 c\nh\nf\nQ\nQ\nBT\n14 0 0 14 287.1504 220.3777 Tm\n[(Visual)31.1 ( Communica)4 (tion)]TJ\n0.017 -1.691 Td\n[(Bachelor\\222)12 (s Degr)26 (ee)]TJ\nET\nq\n0 841.89 595.275 -841.89 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm12 Do\nQ\n0.647 0.655 0.663 rg\nq 1 0 0 1 393.2729 149.9565 cm\n0 0 m\n0 -2.498 -2.043 -4.54 -4.54 -4.54 c\n-105.268 -4.54 l\n-107.765 -4.54 -109.808 -2.498 -109.808 0 c\n-109.808 8.92 l\n-109.808 11.417 -107.765 13.46 -105.268 13.46 c\n-4.54 13.46 l\n-2.043 13.46 0 11.417 0 8.92 c\nh\nf\nQ\nQ\nBT\n14 0 0 14 287.1504 149.5115 Tm\n[(Gr)7 (aphic Design)]TJ\n/C2_1 1 Tf\n0.016 -1.691 Td\n[<0029004D0054005000530051004500030028004900560058004D01F000470045>4 <0058>13.1 <0049>]TJ\nET\nq\n42.533 419.417 m\n42.533 417.653 l\n42.974 403.236 54.181 391.528 68.386 390.296 c\n68.386 390.296 l\n73.348 390.296 l\n87.297 391.506 98.355 402.817 99.166 416.877 c\n99.166 416.877 l\n99.166 420.193 l\n98.308 435.077 85.966 446.882 70.867 446.882 c\n70.867 446.882 l\n55.507 446.882 42.999 434.665 42.533 419.417 c\nW n\nq\n56.6326348 0 0 56.6326348 42.5332031 390.2955878 cm\n/Im1 Do\nQ\nQ\nq\n42.533 348.551 m\n42.533 346.787 l\n42.974 332.372 54.176 320.668 68.375 319.431 c\n68.375 319.431 l\n73.358 319.431 l\n87.303 320.645 98.356 331.954 99.166 346.011 c\n99.166 346.011 l\n99.166 349.327 l\n98.308 364.211 85.966 376.016 70.867 376.016 c\n70.867 376.016 l\n55.507 376.016 42.999 363.799 42.533 348.551 c\nW n\nq\n56.6326392 0 0 56.6326392 42.5330099 319.4306658 cm\n/Im2 Do\nQ\nQ\nq\n42.533 277.685 m\n42.533 275.92 l\n42.974 261.506 54.176 249.801 68.376 248.564 c\n68.376 248.564 l\n73.358 248.564 l\n87.302 249.779 98.356 261.088 99.166 275.144 c\n99.166 275.144 l\n99.166 278.46 l\n98.308 293.344 85.966 305.149 70.867 305.149 c\n70.867 305.149 l\n55.507 305.149 42.999 292.931 42.533 277.685 c\nW n\nq\n56.6326348 0 0 56.6326348 42.5332031 248.5636542 cm\n/Im3 Do\nQ\nQ\nq\n42.533 206.818 m\n42.533 205.053 l\n42.974 190.642 54.17 178.939 68.365 177.698 c\n68.365 177.698 l\n73.369 177.698 l\n87.309 178.916 98.356 190.224 99.166 204.277 c\n99.166 204.277 l\n99.166 207.593 l\n98.308 222.477 85.966 234.282 70.867 234.282 c\n70.867 234.282 l\n55.507 234.282 42.999 222.065 42.533 206.818 c\nW n\nq\n56.6326392 0 0 56.6326392 42.5330099 177.698244 cm\n/Im4 Do\nQ\nQ\nq\n42.533 106.831 56.632 56.633 re\nW n\nq\n56.6326348 0 0 56.6326348 42.5332031 106.8312324 cm\n/Im5 Do\nQ\nQ\nq\n170.391658 0 0 170.391658 42.5043956 629.3142286 cm\n/Im6 Do\nQ\nq\n0 841.89 595.275 -841.89 re\nW n\n0.502 0.502 0.506 rg\nq 1 0 0 1 114.5386 68.7602 cm\n0 0 m\n0.86 0.543 1.52 1.403 1.829 2.428 c\n1.024 1.925 0.134 1.561 -0.815 1.363 c\n-1.573 2.217 -2.655 2.75 -3.854 2.75 c\n-6.153 2.75 -8.016 0.784 -8.016 -1.641 c\n-8.016 -1.985 -7.98 -2.321 -7.909 -2.64 c\n-11.368 -2.457 -14.436 -0.711 -16.49 1.947 c\n-16.849 1.297 -17.054 0.543 -17.054 -0.261 c\n-17.054 -1.784 -16.319 -3.128 -15.202 -3.917 c\n-15.884 -3.895 -16.525 -3.694 -17.088 -3.368 c\n-17.088 -3.423 l\n-17.088 -5.55 -15.654 -7.325 -13.747 -7.728 c\n-14.098 -7.83 -14.464 -7.882 -14.845 -7.882 c\n-15.113 -7.882 -15.375 -7.856 -15.627 -7.804 c\n-15.099 -9.548 -13.562 -10.819 -11.738 -10.853 c\n-13.165 -12.031 -14.959 -12.732 -16.91 -12.732 c\n-17.246 -12.732 -17.578 -12.714 -17.902 -12.672 c\n-16.061 -13.917 -13.873 -14.645 -11.521 -14.645 c\n-3.862 -14.645 0.324 -7.953 0.324 -2.15 c\n0.324 -1.96 0.321 -1.77 0.312 -1.583 c\n1.126 -0.964 1.834 -0.189 2.391 0.691 c\n1.644 0.342 0.841 0.105 0 0 c\nf\nQ\nq 1 0 0 1 73.4434 54.1157 cm\n0 0 m\n-4.272 0 l\n-4.272 6.795 l\n-4.272 8.574 -4.94 9.786 -6.41 9.786 c\n-7.534 9.786 -8.159 8.968 -8.449 8.178 c\n-8.559 7.896 -8.542 7.5 -8.542 7.104 c\n-8.542 0 l\n-12.773 0 l\n-12.718 12.036 -12.773 13.13 v\n-8.542 13.13 l\n-8.542 11.069 l\n-8.292 11.97 -6.939 13.257 -4.781 13.257 c\n-2.104 13.257 0 11.366 0 7.301 c\nh\n-17.053 14.772 m\n-17.08 14.772 l\n-18.444 14.772 -19.327 15.776 -19.327 17.047 c\n-19.327 18.343 -18.417 19.327 -17.027 19.327 c\n-15.636 19.327 -14.783 18.346 -14.755 17.049 c\n-14.755 15.779 -15.636 14.772 -17.053 14.772 c\n-18.84 13.13 3.768 -13.128 re\nf\nQ\nq 1 0 0 1 243.3013 65.5693 cm\n0 0 m\n-2.593 -1.625 -4.562 -2.888 -5.907 -3.79 c\n-6.358 -4.096 -6.724 -4.336 -7.005 -4.507 c\n-7.285 -4.68 -7.659 -4.856 -8.126 -5.035 c\n-8.593 -5.214 -9.027 -5.304 -9.431 -5.304 c\n-9.442 -5.304 l\n-9.455 -5.304 l\n-9.858 -5.304 -10.293 -5.214 -10.76 -5.035 c\n-11.227 -4.856 -11.6 -4.68 -11.881 -4.507 c\n-12.161 -4.336 -12.527 -4.096 -12.979 -3.79 c\n-14.046 -3.064 -16.012 -1.8 -18.875 0 c\n-19.325 0.278 -19.725 0.597 -20.073 0.956 c\n-20.073 -7.764 l\n-20.073 -8.247 -19.887 -8.661 -19.515 -9.004 c\n-19.144 -9.349 -18.697 -9.521 -18.175 -9.521 c\n-0.712 -9.521 l\n-0.189 -9.521 0.258 -9.349 0.63 -9.004 c\n1.001 -8.66 1.187 -8.247 1.187 -7.764 c\n1.187 0.956 l\n0.847 0.604 0.451 0.286 0 0 c\n-18.032 1.175 m\n-17.764 0.999 -16.953 0.478 -15.601 -0.39 c\n-14.248 -1.257 -13.212 -1.925 -12.492 -2.394 c\n-12.413 -2.445 -12.245 -2.557 -11.988 -2.729 c\n-11.731 -2.9 -11.517 -3.04 -11.347 -3.146 c\n-11.177 -3.252 -10.972 -3.371 -10.73 -3.502 c\n-10.489 -3.634 -10.262 -3.734 -10.049 -3.799 c\n-9.834 -3.865 -9.637 -3.898 -9.455 -3.898 c\n-9.442 -3.898 l\n-9.432 -3.898 l\n-9.249 -3.898 -9.051 -3.865 -8.838 -3.799 c\n-8.625 -3.734 -8.396 -3.634 -8.155 -3.502 c\n-7.915 -3.371 -7.709 -3.252 -7.538 -3.146 c\n-7.368 -3.04 -7.155 -2.9 -6.898 -2.729 c\n-6.641 -2.557 -6.473 -2.445 -6.394 -2.394 c\n-5.666 -1.925 -3.815 -0.736 -0.842 1.175 c\n-0.264 1.548 0.218 1.998 0.606 2.526 c\n0.994 3.053 1.187 3.604 1.187 4.184 c\n1.187 4.667 0.999 5.081 0.623 5.424 c\n0.247 5.768 -0.197 5.941 -0.712 5.941 c\n-18.175 5.941 l\n-18.783 5.941 -19.252 5.751 -19.581 5.37 c\n-19.908 4.989 -20.073 4.513 -20.073 3.942 c\n-20.073 3.48 -19.855 2.982 -19.421 2.443 c\n-18.985 1.905 -18.523 1.482 -18.032 1.175 c\nf\nQ\nq 1 0 0 1 191.3931 73.0751 cm\n0 0 m\n5.485 -8.188 l\n7.19 -6.997 l\n1.719 1.205 l\nh\n7.945 3.267 m\n5.897 2.903 l\n7.562 -6.871 l\n9.609 -6.506 l\nh\n4.701 -20.19 m\n-8.055 -20.19 l\n-8.055 -11.525 l\n-9.718 -11.525 l\n-9.718 -21.844 l\n-9.705 -21.844 l\n-9.223 -21.858 l\n6.338 -21.858 l\n6.338 -21.844 l\n6.352 -21.354 l\n6.352 -11.525 l\n4.701 -11.525 l\nh\n3.919 -10.894 m\n-5.47 -8.329 l\n-6.006 -10.375 l\n3.383 -12.941 l\nh\n5.142 -8.482 m\n-3.229 -3.435 l\n-4.288 -5.258 l\n4.083 -10.305 l\nh\n3.038 -16.376 m\n-6.68 -16.39 l\n-6.68 -18.508 l\n3.038 -18.493 l\nh\n3.272 -13.671 m\n-6.405 -12.76 l\n-6.598 -14.862 l\n3.094 -15.773 l\nh\nf\nQ\nq 1 0 0 1 137.2227 63.4848 cm\n0 0 m\n0 -5.253 3.322 -9.709 7.93 -11.28 c\n8.51 -11.391 8.722 -11.024 8.722 -10.708 c\n8.722 -10.426 8.711 -9.679 8.706 -8.687 c\n5.48 -9.405 4.8 -7.093 y\n4.272 -5.718 3.513 -5.353 y\n2.459 -4.614 3.592 -4.63 y\n4.756 -4.715 5.368 -5.855 y\n6.403 -7.672 8.083 -7.147 8.744 -6.843 c\n8.848 -6.075 9.148 -5.551 9.48 -5.254 c\n6.904 -4.953 4.197 -3.933 4.197 0.622 c\n4.197 1.92 4.649 2.982 5.391 3.813 c\n5.272 4.115 4.875 5.323 5.504 6.959 c\n6.479 7.28 8.693 5.741 v\n9.62 6.005 10.61 6.136 11.596 6.142 c\n12.582 6.136 13.574 6.005 14.5 5.741 c\n16.713 7.28 17.686 6.959 y\n18.319 5.323 17.92 4.115 17.801 3.813 c\n18.545 2.982 18.993 1.92 18.993 0.622 c\n18.993 -3.944 16.282 -4.951 13.699 -5.245 c\n14.115 -5.612 14.484 -6.338 14.484 -7.446 c\n14.484 -9.037 14.472 -10.318 14.472 -10.708 c\n14.472 -11.026 14.681 -11.396 15.27 -11.28 c\n19.873 -9.705 23.192 -5.251 23.192 0 c\n23.192 6.567 18 11.89 11.596 11.89 c\n5.192 11.89 0 6.567 0 0 c\nf\nQ\nEMC \n/OC /MC4 BDC \nQ\nq\n43.937 43.937 39.685 39.686 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm13 Do\nQ\nBT\n/TT4 1 Tf\n6 0 0 6 45.3545 77.0391 Tm\n(Link http://bit.ly/GeriBorbasLinkedIn)Tj\nET\nQ\nq\n86.457 43.937 39.685 39.686 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm14 Do\nQ\nBT\n/TT4 1 Tf\n6 0 0 6 87.8735 77.0391 Tm\n[(Link http://bit.ly/GeriBorbasT)55 (witter)]TJ\nET\nQ\nq\n128.976 43.937 39.685 39.686 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm15 Do\nQ\nBT\n/TT4 1 Tf\n6 0 0 6 130.3936 77.291 Tm\n(Link http://bit.ly/GeriBorbasGitHub)Tj\nET\nQ\nq\n171.496 43.937 39.685 39.686 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm16 Do\nQ\nBT\n/TT4 1 Tf\n6 0 0 6 172.9136 77.291 Tm\n(Link http://bit.ly/GeriBorbasStackOverflow)Tj\nET\nQ\nq\n214.016 43.937 130.394 39.686 re\nW n\nq\n0 g\n/GS1 gs\n0 TL/Fm17 Do\nQ\nBT\n/TT4 1 Tf\n6 0 0 6 215.4331 77.0391 Tm\n(Link mailto:geri@eppz.eu)Tj\nET\nEMC \n/OC /MC5 BDC \nEMC \n/OC /MC6 BDC \nEMC \n/OC /MC7 BDC \nEMC \n/OC /MC8 BDC \nEMC \n/OC /MC9 BDC \nEMC \n/OC /MC10 BDC \nEMC \n/OC /MC11 BDC \nEMC \n/OC /MC12 BDC \nEMC \n/OC /MC13 BDC \nEMC \n/OC /MC14 BDC \nEMC \n/OC /MC15 BDC \nEMC \n/OC /MC16 BDC \nEMC \n/OC /MC17 BDC \nEMC \n/OC /MC18 BDC \nEMC \n/OC /MC19 BDC \nEMC \n/OC /MC20 BDC \nEMC \n/OC /MC21 BDC \nEMC \n/OC /MC22 BDC \nEMC \n/OC /MC23 BDC \nEMC \n/OC /MC24 BDC \nEMC \n/OC /MC25 BDC \nEMC \n/OC /MC26 BDC \nEMC \n/OC /MC27 BDC \nEMC \n/OC /MC28 BDC \nEMC \n/OC /MC29 BDC \nEMC \n/OC /MC30 BDC \nEMC \nQ\n"

// Match.
let matches = regex.matches(in: contents, options: [], range: contents.entireRange)

func logGroupRange(_ eachGroupRange: NSRange, as name: String, in string: String)
{
    if let eachRangeBounds = Range(eachGroupRange, in: string)
    {
        print(
            String(
                format: "Group %@ %@: `%@`",
                name,
                eachGroupRange.description,
                String(string.substring(with: eachRangeBounds).prefix(40))
            )
        )
    }
}

// Enumerate matches.
for (eachMatchIndex, eachMatch) in matches.enumerated()
{
    print("Match (\(eachMatchIndex))")
    
    // Log groups.
    (0...eachMatch.numberOfRanges - 1).forEach
    {
        eachGroupIndex in
        logGroupRange(eachMatch.range(at: eachGroupIndex), as: "\(eachGroupIndex)", in: contents)
    }
    
    // Log named groups.
    logGroupRange(eachMatch.range(withName: "x"), as: "x", in: contents)
    logGroupRange(eachMatch.range(withName: "y"), as: "y", in: contents)
    logGroupRange(eachMatch.range(withName: "width"), as: "width", in: contents)
    logGroupRange(eachMatch.range(withName: "height"), as: "height", in: contents)
    logGroupRange(eachMatch.range(withName: "text"), as: "text", in: contents)
}

// Replace matches.
let body = regex.stringByReplacingMatches(in: contents, options: [], range: contents.entireRange, withTemplate: Constants.replacementTemplate)

// Insert into template.
let originalHtml = Constants.htmlTemplate.replacingOccurrences(of: Constants.bodyTemplate, with: contents)
let replacedHtml = Constants.htmlTemplate.replacingOccurrences(of: Constants.bodyTemplate, with: body)

// Write.
try! originalHtml.write(to: Constants.originalHtmlFileName)
try! replacedHtml.write(to: Constants.replacedHtmlFileName)


    
