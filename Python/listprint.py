movies = ["Item1","item2","item3",20,21,["level2",["level3", 22, 44],"level2"]]

def listprint(List):
    for i in List:
        if isinstance(i, list):
            listprint(i)
        else:
            print (i)

listprint(movies)