import csv
import json
import os


UnitFilePath = os.path.dirname(__file__)+'/Units'
UnitJsonFile = os.path.dirname(__file__)+'/Units.json'

UnitJsonData:dict = {}
with open(UnitFilePath, 'r', encoding='utf-8') as f:
    curid = 0
    writer = csv.reader(f)
    for row in writer:
        if row[0]=='':
            continue
        if curid==0:
            curid+=1
            continue
        UnitJsonData[curid] = {
            'Name':row[1],
            'World':row[2],
            'Description':row[3],
            'Hp':row[4],
            'Atk':row[5],
            'Pt':row[6],
            'AbilityDescription':row[7],
            'Texture':row[0]+'.png',
        }
        curid+=1
with open(UnitJsonFile, 'w', encoding='utf-8') as f:
    f.write(json.dumps(UnitJsonData))


print('enum {')
CurrentWorld = ''
for unit in UnitJsonData:
    unitdat = UnitJsonData[unit]
    
    if CurrentWorld!=unitdat['World']:
        print('\n# ~ '+unitdat['World']+' ~ ')
        CurrentWorld = unitdat['World']

    EnumName:str = (unitdat['World']+"_"+unitdat['Name'])
    EnumName = EnumName.replace(" ","").replace(".","").replace(",","").replace("'","").replace("-","")
    FinalLine = EnumName+' = '+str(unit)+','
    print(FinalLine)
print('}')
