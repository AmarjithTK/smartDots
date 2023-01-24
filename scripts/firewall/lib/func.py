



from bs4 import BeautifulSoup
import re,json,subprocess,os





# while True:

#     val = subprocess.getoutput("pgrep -f chrome")

#     if val :
#         print("running")

#     else:
#         print("stopped")  



def isRunning(process):
    val = subprocess.getoutput(f"pgrep -f {process}")

    if val:
        return True
    else:
        return False



# import psutil





# def checkIfProcessRunning(processName):
#     '''
#     Check if there is any running process that contains the given name processName.
#     '''
#     #Iterate over the all the running process
#     for proc in psutil.process_iter():
#         try:
#             # Check if process name contains the given name string.
#             if processName.lower() in proc.name().lower():
#                 return True
#         except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
#             pass
#     return False;


def formExtract(soup):

    form = soup.find('form')
    inputredir= ''
    inputmagic=''
    
    for input in form.findAll("input"):
        print(input)

        if(input.has_attr("name") and input.get("name") == 'magic'):
            inputmagic = input.get("value")
        if(input.has_attr("name") and input.get('name') == '4Tredir'):
            inputredir = input.get('value')


    print("this is inputmagic",inputmagic,inputredir)
        

    #return {"4Tredir":inputmagic,"magic":inputredir}
    return {'inputmagic' :inputmagic,'inputredir':inputredir}






def authError(soup):
    if "Failed" in soup.text:
        return True

    return False    

def concurrentError(soup):
    if "concurrent" in soup.text:
        return True

    return False



def readFile(filename):

    try:
        with open(filename, 'r') as jsonf:
            codearray = json.load(jsonf)


    except:
        codearray = {

           
    "user": [],
    "keepaliveurl":"null",
    "loginurl":"null",
    "logouturl":"null",
    "timeout":"6400",
    "status":"up",
    "loggeduser":"amarjith"




        }
    

    return codearray



def writeToFile(codearray,filename):

    with open(filename, "w") as testfile:
        json.dump(codearray, testfile)





def showDialogHTML(infostack,basedir):

    file_html = open(f"{basedir}/message.html", "w")

    htmlstring = ""

    for idli in infostack:

        htmlstring += f"<a href='{idli}'>{idli}</a><br>"


    # Adding the input data to the HTML file
    file_html.write(f'''<html>
    <head>
    <title>keepalive window</title>
    </head> 
    <body>
    <h1>Amarjith TK </h1>           

        <hr>

        {htmlstring}

    </body>
    </html>''')
    
    # Saving the data into the HTML file
    file_html.close()

    run3 = subprocess.getoutput(
        f"google-chrome-stable file://{basedir}/message.html")



def extractTimeRemaining(body):
        pattern = r"countDownTime=(\d+)"
        extract = re.findall(pattern, body)
        return extract[0]



def extractParams(url):

    # url =  'http://192.168.65.1:1000/keepalive?0b0d07010e13a8ac' 

    pattern = r"(http:\/\/[\d|\.]+:\d*\/)([a-zA-Z]+)\?(.+)"    
    extract = re.findall(pattern, url)

    return extract[0]



def findPageLinks(soup):
    # soup = getSoup(body)

    print(soup)
    # pattern = r"http:\/\/[\d|\.]+:\d+\/[a-zA-Z]+\?.+"
    souplinks = soup.findAll('a')
    

    print(souplinks)
    # souplinks = re.findall(pattern, body.text)


    souplinks = map(lambda x:x.get('href'), souplinks)

    print(souplinks)

    # linkurls = []

    # for link in souplinks:
    #     # linkurls.append(link.get('href'))

    return souplinks

    # return linkurls 

    


def logOutFromFirewall(url,session):

    logout = session.get(url)

    return session




def getSoup(output):
    soup = BeautifulSoup(output.text,'html.parser')
    
    return soup


def jsonObjGen(codearray, keepaliveurl,loginurl,logouturl,timeout,status,loggeduser):

    keepaliveurl = keepaliveurl if keepaliveurl!=None else codearray['keepaliveurl']
    loginurl = loginurl if loginurl !=None else codearray['loginurl']
    logouturl = logouturl if logouturl !=None else codearray['logouturl']
    timeout = timeout if timeout !=None else codearray['timeout']
    status = status if status !=None else codearray['status']
    loggeduser = loggeduser if loggeduser !=None else codearray['loggeduser']


    jsonobj = {

        "user":codearray["user"],
        "keepaliveurl":keepaliveurl,
        "loginurl":loginurl,
        "logouturl":logouturl,
        "timeout":timeout,
        "status":status,
        "loggeduser":loggeduser,

    }

    return jsonobj


