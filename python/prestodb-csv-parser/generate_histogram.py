#!/usr/bin/env python
"""Generate histogram from prestodb data."""

import argparse
import csv
import re
import sys
import pdb
import matplotlib.pyplot as plt
import numpy as np

from collections import defaultdict

CSV_FILE = "/Users/tnation/Downloads/a04d61ec-0dbe-4741-8e14-10aef580ff08.csv"


class GraphMaker(object):
    """Graph maker base class."""

    def __init__(self):
        """Initialize graph data."""
        self.graph_data = defaultdict(list)

    @property
    def xs(self):
        """List values along the x axis."""
        return filter(lambda x: x != "quartiles", self.graph_data.keys())

    def draw_graph(self, name):
        """Daraw a graph with the given name."""
        pass

    def update_graph_data(self, key, value):
        """Update graph data."""
        pass


class HistogramMaker(GraphMaker):
    """Generates a histogram from PrestoDB data."""

    def __init__(self):
        """Initialize graph data."""
        super(HistogramMaker, self).__init__()

    def update_graph_data(self, tool, histogram):
        """Add histogram data to dictionary."""
        for key, value in (kv.split("=") for kv in re.sub(r'[\{\}]', '', histogram).split(',')):  # NOQA E501
            self.graph_data[tool].extend(
                [int(key.replace(' ', ''))] * int(value))

        if self.graph_data[tool]:
            quartiles = map(lambda y: max(filter(lambda x: x <= np.percentile(self.graph_data[tool], y, axis=0),
                self.graph_data[tool])), [25, 50, 75])
            print "%s: %s" % (tool, ", ".join(map(str, quartiles)))

    def draw_graph(self, name):
        """Draw a histogram based on graph data."""
        map(lambda x: self.show_histogram(x, self.graph_data[x]),
            self.xs)

    def show_histogram(self, name, histogram_list):
        """Another method of showing the histogram."""
        print name
        plt.hist(filter(lambda x: x > 3000, histogram_list))
        plt.title(name)
        plt.show()


class BarMaker(GraphMaker):
    """Class to make bar graph from key,value pairs."""

    def __init__(self):
        """Initialize graph data."""
        super(BarMaker, self).__init__()

    @property
    def ys(self):
        """Get y values from graph dict."""
        return self.graph_data.values()

    def update_graph_data(self, key, value):
        """Add bar data to dictionary."""
        self.graph_data[key] = value

    def draw_graph(self, name):
        """Draw a graph with the given name."""
        self.show_bar(name)

    def show_bar(self, name):
        """Construct a bar graph."""
        pos = np.arange(len(self.xs))
        width = 1.0     # gives histogram aspect to the bar diagram

        ax = plt.axes()
        ax.set_xticks(pos + (width / 2))
        ax.set_xticklabels(self.xs)
        plt.bar(self.xs, self.ys, width)
        plt.title(name)
        plt.show()


class GraphMakerFactory(object):
    """Factory object to generate graph maker based on user input."""

    def __init__(self, graph_type):
        """Set graph maker."""
        makers = {'Histogram': HistogramMaker,
                  'Bar': BarMaker}
        if graph_type not in makers.keys():
            raise Exception("%s graph is not supported", graph_type)
        self.graph_maker = makers[graph_type]

    def get_maker(self):
        """Create a graph maker."""
        return self.graph_maker()


def main():
    """Read CSV file into dictionary and generate plot."""
    parser = argparse.ArgumentParser(
        description='Generate graph from prestodb data')
    parser.add_argument('--graph-type', required=True,
                        choices=['Histogram', 'Bar'],
                        help='Type of graph you want to create.')
    parser.add_argument('--filename', required=True,
                        help='Name of input file.')

    args = parser.parse_args()

    factory = GraphMakerFactory(args.graph_type)
    maker = factory.get_maker()

    csv.field_size_limit(sys.maxsize)
    with open(args.filename, "r") as f:
        reader = csv.reader(f)
        reader.next()
        for row in reader:
            maker.update_graph_data(row[0], row[1])

    # print "Mode lower quartile: %d" % max(set(maker.graph_data['quartiles']), key=maker.graph_data['quartiles'].count)



if __name__ == '__main__':
    main()
