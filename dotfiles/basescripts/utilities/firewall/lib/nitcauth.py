import requests
from .func import *
import time

# _____________ Util functions _____________________________


# _______________ To be abstracted to file ---------


# this program has big flaw, it will consider timeout as nothing

# ----------- supppose timeout happens, the program considers it as logged in as the variable did not chagnge to offline




class NITCAuth:


    # codearray = readFile("test.json")

    def setFileData(self,filename):


        codearray = readFile(filename)

        # print(codearray)

        self.user = codearray['user']
        self.keepaliveurl = codearray['keepaliveurl']
        self.loginurl=codearray['loginurl']
        self.logouturl =codearray['logouturl']
        self.timeout = codearray['timeout']
        self.status=codearray['status']
        self.loggeduser = codearray['loggeduser']

        self.triggered = False  

    # self.setFileData('test.json')


    def __init__(self, filename,basedir):

        self.filename = filename

        self.session = requests.session()
        self.setFileData(filename)

        self.basedir =basedir

        # self.session =
        
    

    def findLoginUrl(self):       # ------------------------------------- find login page is redundant , auto redirection done '
        redirect = self.session.get("http://www.gstatic.com/generate_204")

        # print(redirectPage.text,"this is redirect page\n\n\n")
        # soup = getSoup(redirectPage)

        # # print(pagesoup,"this is \n")
        # links = findPageLinks(soup)

        # # print("links",links)

        
        if "192.168" in redirect.url:
                return redirect.url

        return None 

    def findLogoutUrl(self,soup):
        links = findPageLinks(soup)

        for link in links:
            if 'logout' in link:
                return link
        return None     



    def getHTMLArray(self):       


        array = [

            self.keepaliveurl,
            self.loginurl,
            self.logouturl,
            self.timeout,
            self.status,
            self.loggeduser

            # self.codearray["keepaliveurl"],
            # self.codearray["loginurl"],
            # self.codearray["logouturl"],
            # self.codearray["timeout"],
            # self.codearray["status"],
            # self.codearray["loggeduser"],

        ]

        return array

    def loggedAlready(self):

        array  = self.getHTMLArray()

        showDialogHTML(array,basedir = self.basedir)







            # if false ==> continue


    def loginToFirewall(self,user):

        

        url = self.findLoginUrl()

        if url == None:
            self.loggedAlready()
            return True


        self.loginurl = url    

        # if error


# keepaliveurl,loginurl

        soup =  self.getRequest(url)

        baseurl = extractParams(url)[0]

        # print(baseurl)


        formextract = formExtract(soup)

        print("This is form extact",formextract)


        print(user)

        userdata = {'username':user['username'],'password':user['password'],'magic':formextract['inputmagic'],'4Tredir':formextract['inputredir']}

        auth_response =  self.session.post(baseurl,data=userdata)

        print('success',auth_response.url)

        soup = getSoup(auth_response)

        # print(soup)

        print(authError(soup),concurrentError(soup))

        print("\n\n\n\n\n\n")


        

        if authError(soup) or concurrentError(soup):
            return False
            

        self.keepaliveurl = auth_response.url
        
        # print(auth_response.text)

        self.timeout = extractTimeRemaining(auth_response.text)

        self.logouturl =  self.findLogoutUrl(soup) if self.findLogoutUrl(soup) != None else self.logouturl

        self.status = 'up'

        self.loggeduser =  user['username']
        
        array  = self.getHTMLArray()

        print(array)

        showDialogHTML(array,basedir=self.basedir) 

        

        writeToFile({"user":self.user,"keepaliveurl":self.keepaliveurl,"loginurl":self.loginurl,"logouturl":self.logouturl,"timeout":self.timeout,"status":self.status,"loggeduser":self.loggeduser},self.filename)      

        return True


    def waitfortrigger(self):




        while True:
            time.sleep(.5)

            status =  isRunning("chrome")
            # print(status)

            print(f"status {status}")
            # verify if using nitc network
            if(status == True and self.triggered == False):
                
                self.loginManager()
                self.triggered = True

            elif status == False and self.triggered == True:
                self.logOutFromFirewall()
                self.triggered = False

           # if no internet curl or something


            else:
                print("critieria not satifsfied")

            # time.sleep(2)
    


    def loginManager(self):


        print("Program controll is here")
        for user in self.user:

            userstatus = self.loginToFirewall(user)

            if userstatus == False:
                continue

            if userstatus == True:
                break

           

        # if authError(soup) or concurrentError(soup)



         # todo : autherror , concurrent


        #  for user in self.codearray['user']:


    def getRequest(self,url):
        response = self.session.get(url)
        return getSoup(response)







        
        

        # for loop to loop through userdata
        # concurrency found then continue
        # # else okay

        # def extractTimeRemaining(body):
        #     pattern = r"countDownTime=(\d+)"
        # pass timeremaining to json

        # time.sleep()

        # give body content soup and check for the word concurrent or limit

    def logOutFromFirewall(self):
        self.session.get(self.logouturl)
        print("logged out")
        return True

        # the uid here is different
        # store both initial and final uid in storage.json
        #
        #
            # get base url
            # get keywords
            # get uid

            # all using regex
