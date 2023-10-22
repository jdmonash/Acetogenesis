#!/usr/bin/env python
#NOTE!! This doesn't need to be run as it's just run as part of the j1 script...

import argparse
def main (input_file, output_file):
    with open (input_file, 'r') as f, open (output_file, 'w') as g:
        header = "genome,completeness,contamination"
        'completeness', 'contamination', 'genome'
        g.write(header + '\n')
        f.readline()
        n = 0
        for line in f:
            genome, compl, cont, *_ = line.strip().split("\t")
            separator = ","
            extension = ".fa"
            string = genome + extension + separator + compl + separator + cont + '\n'
            n += 1
            g.write(string)
        print(f"converted {n} genomes")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="converts tsv from checkm2 into csv suitable for drep",
        epilog="example: ./convert_checkm.py path/quality_report.tsv path")
    parser.add_argument("input_file", help="File quality assessed by checkm2")
    parser.add_argument("output_file", help="output to be used in drep")
    args = parser.parse_args()
    main(args.input_file, args.output_file)
