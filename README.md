# TextPaths

**TextPaths** is an utility for converting `NSAttributedText` to vector representation where each character of an input text is represented as a `CGPAth` glyph. **TextPaths** also returns typographic propeties for lines and entire text flow.

Source `NSAttributedText` is converted into a tree like representation with char glyphs on leafs.

```
 TextPath
    ⎿ TextPathFrame[]
        ⎿ TextPathLine[]
            ⎿ TextPathGlyph[]

    ⎿ ComposedTextPath
```

`TextPathFrame` - text frame representation

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-01.jpg" height="120" width="auto"/>

`TextPathLine` - single text line representation

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-02.jpg" height="120" width="auto"/>

There is also a text bounds rectangle available. Text bounds rectangle is equal or less then line bounds rectangle. On image below this metric is show in purple.

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-03.jpg" height="120" width="auto"/>

`TextPathGlyph` - single character representation (glyph)

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-04.jpg" height="120" width="auto"/>

`ComposedTextPath` - composed path of entire input text. This is illustrated on all images above in black.

All illustrations were created with [`TextDecompose`](https://github.com/malczak/TextPaths/tree/master/Samples/TextDecompose) sample application.
