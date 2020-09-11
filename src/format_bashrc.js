const fs = require('fs')
const path = require('path')
const os = require('os')

const bash_rc_path = path.join(os.homedir(), '.bashrc')

/** @type {string} */
let bashrc_source = fs.readFileSync(bash_rc_path, 'utf-8')

const aliases_regex = /^\s*aliases=\(\n(.*)\n\)\s*$/gm
const theme_regex = /^(\s*OSH_THEME=)"(.*)"(\s*)$/gm

// finding aliases.
let aliases = new Set()

// eslint-disable-next-line no-constant-condition
while (true) {
  const m = aliases_regex.exec(bashrc_source)
  if (m == null) break
  m[1]
    .replace(/\s+/g, ' ')
    .split(' ')
    .filter(v => v.trim() != '')
    .forEach(v => {
      aliases.add(v)
    })
}

// add as last
aliases.add('z-lib-config')

aliases = Array.from(aliases)

const aliases_string = `aliases=(
  ${aliases.join('\n  ')}
)`

console.log(`New alias list: ${aliases.join(',')}`)

bashrc_source = bashrc_source.replace(aliases_regex, aliases_string)

if (bashrc_source.indexOf('export ZLIB_BASH_CONFIG="true"') == -1) {
  fs.copyFileSync(bash_rc_path, bash_rc_path + '.old.zlib')
  bashrc_source = `${bashrc_source}\nexport ZLIB_BASH_CONFIG="true"\n`
}

bashrc_source = bashrc_source.replace(theme_regex, '$1"z-lib-bash"$3')

fs.writeFileSync(bash_rc_path, bashrc_source)
