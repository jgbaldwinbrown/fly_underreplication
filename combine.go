package main

import (
	"fmt"
	"compress/gzip"
	"os"
	"encoding/csv"
	"io"
	"bufio"
	"strings"
)

var stdin = bufio.NewReader(os.Stdin)
var stdout = bufio.NewWriter(os.Stdout)

func GzCsvOpen(path string) (*os.File, *gzip.Reader, *csv.Reader, error) {
	h := func(err error) (*os.File, *gzip.Reader, *csv.Reader, error) {
		return nil, nil, nil, fmt.Errorf("GzCsvOpen: %w", err)
	}

	fp, e := os.Open(path)
	if e != nil { return h(e) }

	gz, e := gzip.NewReader(fp)
	if e != nil { return h(e) }

	csvr := csv.NewReader(gz)
	csvr.Comma = rune('\t')
	csvr.ReuseRecord = true
	csvr.FieldsPerRecord = 2
	csvr.LazyQuotes = true

	return fp, gz, csvr, nil
}

func AppendPath(out [][]string, pathi int, path string) ([][]string, error) {
	h := func(e error) ([][]string, error) { return nil, fmt.Errorf("AppendPath: %w", e) }

	fp, gz, csvr, e := GzCsvOpen(path)
	if e != nil { return h(e) }

	defer fp.Close()
	defer gz.Close()

	for i := 0; ; i++ {
		l, e := csvr.Read();
		if e == io.EOF { break; }
		if e != nil { return h(e) }

		if pathi == 0 {
			out = append(out, []string{})
			out[i] = append(out[i], l[0])
		}

		out[i] = append(out[i], l[1])
	}

	return out, nil
}

func CombineFiles(in io.Reader, out io.Writer) error {
	h := func(e error) error { return fmt.Errorf("CombineFiles: %w", e) }
	input, e := io.ReadAll(in)
	if e != nil { return h(e) }
	paths := strings.Split(string(input), "\n")
	paths = paths[0:len(paths)-1]

	var outc [][]string
	for i, path := range paths {
		outc, e = AppendPath(outc, i, path)
		if e != nil { return h(e) }
	}

	w := csv.NewWriter(out)
	defer w.Flush()
	w.Comma = rune('\t')
	return w.WriteAll(outc)
}

func main() {
	defer stdout.Flush()

	e := CombineFiles(stdin, stdout)
	if e != nil { panic(e) }
}
