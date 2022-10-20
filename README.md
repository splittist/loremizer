# Loremizer

Replace the text of Microsoft Word documents with *lorem ipsum* text.

**Loremizer** takes a `docx` file and returns a `docx` file with the words replaced by words from the classic *lorem ipsum* nonsense latin. The formatting and layout is preserved (with the exception of linebreaks etc, arising from the difference in the length of the original and replacement words).

**Loremizer** does not alter numbers or punctuation. It also does not replace certain words often used for cross-references, such as "chapter", "section" or "clause", or single letters or roman numerals (which are also often used in cross-references).

One possible use for **Loremizer** is to be able to share a document that has formatting issues while not sharing the confidential text of the document.

Note that **Loremizer** does **NOT** remove metadata from the document. This can be done with Word's built-in [Document Inspector](https://support.microsoft.com/en-us/topic/remove-hidden-data-and-personal-information-by-inspecting-documents-presentations-or-workbooks-356b7b5d-77af-44fe-a07f-9aa4d085966f) feature.

## Usage

*function* **LOREMIZE** *infile* &key *outfile* *reset-dictionary*
Replaces the text in *infile* (a `docx` file) with lorem ipsum text and writes the resulting `docx` file to *outfile* (which defaults to a path the same as *infile* with "Lorem-" prepended to the file name). If *reset-dictionary* is true, the dictionary tracking the mapping of *infile* words to lorem ipsum words will be cleared.

*function* **RESET-DICTIONARY**
Clears the dictionary tracking the mapping of input words to lorem ipsum words.