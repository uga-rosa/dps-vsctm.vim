import { Rule } from "./common.ts";
import { Denops, ensureArray, ensureString, g } from "./deps.ts";
import { highlight } from "./highlight.ts";
import { Tokenizer } from "./token.ts";

export async function main(denops: Denops): Promise<void> {
  const extensions_path = await g.get(
    denops,
    "vsctm_extensions_path",
  ) as string;
  const tokenizer = new Tokenizer(denops, extensions_path);
  const user_rule = await g.get(
    denops,
    "vsctm_rule",
  ) as { [scopeName: string]: Rule };

  denops.dispatcher = {
    async highlight(path: unknown, lines: unknown): Promise<void> {
      const filepath = ensureString(path);
      if (!fileExists(filepath)) {
        return;
      }
      await tokenizer.parse(filepath, ensureArray<string>(lines))
        .then(([tokens, scopeName]) => {
          highlight(denops, tokens, user_rule[scopeName] || {});
        })
        .catch(() => {
          denops.cmd("syntax on");
        });
    },
  };
}

const fileExists = (filepath: string): boolean => {
  try {
    const file = Deno.statSync(filepath);
    return file.isFile;
  } catch {
    return false;
  }
};
