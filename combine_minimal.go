package main

import (
	"strings"
	"fmt"
	"compress/gzip"
	"os"
	"encoding/csv"
	"io"
	"bufio"
)

var stdin = bufio.NewReader(os.Stdin)
var stdout = bufio.NewWriter(os.Stdout)

func GzOpen(path string) (*os.File, *gzip.Reader, error) {
	h := func(err error) (*os.File, *gzip.Reader, error) {
		return nil, nil, fmt.Errorf("GzCsvOpen: %w", err)
	}

	fp, e := os.Open(path)
	if e != nil { return h(e) }

	gz, e := gzip.NewReader(fp)
	if e != nil { return h(e) }

	return fp, gz, nil
}

func AppendPath(out [][]string, pathi int, path string) ([][]string, error) {
	fp, gz, e := GzOpen(path)
	if e != nil { return nil, e }
	defer fp.Close()
	defer gz.Close()

	s := bufio.NewScanner(gz)

	i := 0
	for s.Scan() {
		if s.Err() != nil {
			return nil, e
		}
		l := strings.Split(s.Text(), "\t")
		if len(l) != 2 {
			return nil, fmt.Errorf("len(l) %v != 2", len(l))
		}

		if pathi == 0 {
			out = append(out, []string{})
			out[i] = append(out[i], l[0])
		}

		out[i] = append(out[i], l[1])
		i++
	}

	return out, nil
}

func CombineFiles(in io.Reader, out io.Writer) error {
	input, e := io.ReadAll(in)
	if e != nil { return e }

	paths := strings.Split(string(input), "\n")
	paths = paths[0:len(paths)-1]

	var outc [][]string
	for i, path := range paths {
		outc, e = AppendPath(outc, i, path)
		if e != nil { return e }
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
