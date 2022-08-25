
import json

hsk = open("./hsk.txt").read()
hsk_lines = hsk.split("\n")
print(len(hsk_lines))

dict_data = open("./dict.txt").read()
dict_lines = dict_data.split("\n")
print(len(dict_lines))

d = {}
data = {}



for line in dict_lines:
    tokens = line.split(" ")
    if len(tokens) > 2:
        w = tokens[1]
        if w not in d:
            d[w] = [line]
        else:
            d[w].append(line)


hsk_dict = []
pinyin_replacements = [
    ["a", "ā", "á", "ǎ", "à"],
    ["e", "ē", "é", "ě", "è"],
    ["i", "ī", "í", "ǐ", "ì"],
    ["o", "ō", "ó", "ǒ", "ò"],
    ["u", "ū", "ú", "ǔ", "ù"],
    ["ü", "ǖ", "ǘ", "ǚ", "ǜ"],
]

def pinyin_convert(s):
    tokens = s.split(" ")
    new_tokens = []
    for t in tokens:
        t = t.replace("u:", "ü")
        tone = int(t[-1:]) % 5
        t = t[:-1]
        for repl in pinyin_replacements:
            if t.find(repl[0]) >= 0:
                t = t.replace(repl[0], repl[tone])
                break
        new_tokens.append(t)
    return new_tokens

for w in hsk_lines:
    if w in d:
        status = "goood"
        if len(d[w]) > 1:
            status = "???"
        translations = []
        for line in d[w]:
            translation = {
                "line": line,
            }
            pinyin_start = line.find("[") + 1
            pinyin_end = line.find("]")
            translation["pinyin"] = pinyin_convert(line[pinyin_start:pinyin_end])
            translations.append(translation)
        hsk_dict.append({
            "hanzi": w,
            "translations": translations,
            "status": status,
        })
    else:
        hsk_dict.append({
            "translations": [],
            "status": "???",
        })




json.dump(hsk_dict, open("hsk.json", "w"), indent=4, sort_keys=True, ensure_ascii=False)