# My Experiment

This experiment was created with [jbr](https://github.com/rubensworks/jbr.js).

## Requirements

* [Node.js](https://nodejs.org/en/) _(1.12 or higher)_

## Installation

Before this experiment can be used, its dependencies must be downloaded first:

```bash
$ npm install
```

## Usage

This experiment uses jbr experiments not yet present in the main repository. Due to this we need to run the following command:

```bash
mkdir node_modules/@rubeneschauzier &&
cp -r node_modules/@jbr-experiment/solidbench-derived-resources node_modules/@rubeneschauzier/solidbench-derived-resources && 
cp -r node_modules/solidbench node_modules/@rubeneschauzier/solidbench &&
cp -r node_modules/rdf-dataset-fragmenter node_modules/@rubeneschauzier/rdf-dataset-fragmenter
```
Generate combinations:

```bash
$ npm run jbr -- generate-combinations
```
Generate the dataset and queries:

```bash
$ npm run jbr -- prepare
```

Run the experiment locally:

```bash
$ npm run jbr -- run
```

The `output/` directory will now contain all experiment results.

## Usage if jbr is installed globally

If [jbr is installed globally](https://github.com/rubensworks/jbr.js/tree/master/packages/jbr#installation),
you can prepare and run this experiment as follows:

```bash
$ jbr prepare
$ jbr run
```
