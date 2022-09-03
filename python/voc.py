
import json

hsk = open("./hsk.txt", encoding="utf8").read()
hsk_lines = hsk.split("\n")
print(len(hsk_lines))

dict_data = open("./dict.txt", encoding="utf8").read()
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

for hsk_line in hsk_lines:
    bracket = hsk_line.find("（")
    w = hsk_line
    if bracket > 0:
        w = hsk_line[:bracket]
    if w in d:
        status = 0
        status_msg = "ok"
        if len(d[w]) > 1:
            status = 2
            status_msg = "more than one meaning"
        translations = []
        liangci = None
        for line in d[w]:
            translation = {
                "raw": line,
            }
            pinyin_start = line.find("[") + 1
            pinyin_end = line.find("]")
            translation["pinyin"] = pinyin_convert(line[pinyin_start:pinyin_end])
            translation["english"] = line.split("/")[1:-1]
            if translation["english"][-1][:3] == "CL:":
                cls = translation["english"][-1][3:].split(",")
                new_transl = ""
                for cl in cls:
                    split_pos = cl.find("|")
                    if split_pos >= 0:
                        cl = cl[split_pos+1:]
                    py_start = cl.find("[")
                    py_tokens = pinyin_convert(cl[py_start:-1])
                    cl = cl[:py_start]
                    for t in py_tokens:
                        cl += t
                    cl += "]"
                    new_transl += cl + ","
                translation["english"] = translation["english"][:-1]
                liangci = new_transl[:-1]
            if status == "ok" and len(translation["english"]) > 5:
                status = 3
                status_msg = "more than five translations"


            translations.append(translation)
        entry = {
            "hanzi": hsk_line,
            "translations": translations,
            "status": status,
            "status_msg": status_msg,
        }
        if liangci:
            entry["liangci"] = liangci
        hsk_dict.append(entry)
    else:
        hsk_dict.append({
            "hanzi": hsk_line,
            "translations": [],
            "status": 1,
            "status_msg": "no translation",
        })


for entry in hsk_dict:
    if entry["status"] == 2:
        translations = []
        for translation in entry["translations"]:
            if len(translation["english"]) > 1:
                translations.append(translation)
            else:
                english = translation["english"][0]
                if english.find("surname") < 0 and english.find("variant of") < 0:
                    translations.append(translation)
        entry["translations"] = translations
        if len(translations) == 1:
            if len(translations[0]["english"]) > 5:
                entry["status"] = 3
                entry["status_msg"] = "more than five translations"
            else:
                entry["status"] = 0
                entry["status_msg"] = "ok"



json.dump(hsk_dict, open("hsk.json", "w", encoding="utf8"), indent=4, sort_keys=True, ensure_ascii=False)
