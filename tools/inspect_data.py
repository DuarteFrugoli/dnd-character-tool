import json

# Check tools.json PT
tools = json.load(open('assets/data/i18n/pt/tools.json', encoding='utf-8'))
print('PT tools keys:', list(tools.keys())[:10])

# Check what background tool proficiencies are in PT i18n
bgs_pt = json.load(open('assets/data/i18n/pt/backgrounds.json', encoding='utf-8'))
for key in ['Charlatan', 'Criminal', 'Entertainer']:
    e = bgs_pt.get(key, {})
    print(f"PT {key}: {e}")

# Check SRD tools.json
tools_srd = json.load(open('assets/data/srd/tools.json', encoding='utf-8'))
print('\nSRD tools (first 5):', tools_srd[:5] if isinstance(tools_srd, list) else list(tools_srd.keys())[:5])

# Check what class equip looks like in review
bg_srd = json.load(open('assets/data/srd/backgrounds.json', encoding='utf-8'))
bg_charlatan = [b for b in bg_srd if b['name'] == 'Charlatan'][0]
print('\nCharlatan full SRD:', json.dumps(bg_charlatan, indent=2))
