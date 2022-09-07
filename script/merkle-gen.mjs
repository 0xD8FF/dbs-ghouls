import { makeTree } from "./merkle.mjs";
import { parseEther } from "@ethersproject/units";
import { join } from "path";
import { writeFile, readFile } from "fs/promises";
import esMain from "es-main";

import { dirname } from "path";
import { fileURLToPath } from "url";

const args = process.argv.slice(2);

const csvFilePath = args[0];
const __dirname = dirname(fileURLToPath(import.meta.url));

const csvFile = await readFile(csvFilePath, "utf8");
const preMintData = await csvToObject(csvFile);

const preMintResultItem = { name: "main" };

preMintResultItem.entries = preMintData.map(({ wallet_address, tier }) => ({
  minter: wallet_address,
  maxCount: 1,
  price:
    tier === "free" ? parseEther("0").toString() : parseEther("0.1").toString(),
}));

async function csvToObject(csv) {
  const cleanCsv = csv.replace(/\r/g, "");
  const lines = cleanCsv.split("\n");
  const headers = lines[0].split(",");
  const result = [];
  for (let i = 1; i < lines.length; i++) {
    const obj = {};
    const currentline = lines[i].split(",");
    for (let j = 0; j < headers.length; j++) {
      obj[headers[j]] = currentline[j];
    }
    result.push(obj);
  }
  return result;
}

async function generateTree() {
  const treeResult = makeTree(preMintResultItem.entries);
  preMintResultItem.entries = treeResult.entries;
  preMintResultItem.root = treeResult.root;
  console.log(preMintResultItem);

  const outputPath = join(__dirname, "gen.json");
  await writeFile(outputPath, JSON.stringify(preMintResultItem, null, 2));
}

if (esMain(import.meta)) {
  await generateTree();
}
