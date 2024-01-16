const { DB } = require("../../sdk")

const { writeFileSync } = require("fs")
const { resolve } = require("path")

const main = async () => {
  const db = new DB({ size: 5, size_json: 16, level: 40, size_txs: 10 })
  await db.init()
  await db.addCollection("colA")
  await db.addCollection("colB")
  let queries = [
    ["colB", "docA", { d: 4 }],
    ["colB", "docC", { d: 4 }],
    ["colB", "docD", { d: 4 }],
    ["colA", "docD", { b: 4 }],
    ["colA", "docA", { b: 5 }],
    ["colB", "docA2", { d: 4 }],
    ["colB", "docC2", { d: 4 }],
    ["colB", "docD2", { d: 4 }],
    ["colA", "docA2", { b: 4 }],
  ]
  const inputs = await db.getRollupInputs({ queries })
  writeFileSync(resolve(__dirname, "input.json"), JSON.stringify(inputs))
}

main()
