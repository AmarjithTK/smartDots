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
        redirect = self.session.get("http://apple.com")

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
#!/bin/bash
# Version : 2.0
# Description : This bash script is used to login to NITC network without any browser. Can be used in Linux systems in robots, servers...etc, where no display is connected such as Raspberry Pi...etc, make sure you have logout.sh script also which can be used to logout later

output=$(curl -m 3 -s 'http://www.gstatic.com/generate_204'--compressed)

# variable used to check whether we are already logged in or not
checkoutput=${output:0:6}

if [ "$checkoutput" != '<html>' ]; then
    echo "Something doesn't seem right. Check if you are already logged in"
    exit
fi

#####################################################################################################################################################
if ! [ -x "$(command -v dialog)" ]; then # if dialog is not installed 
    # reading username and password to be used from user, the password will be hidden while typing
    read -p 'Username: ' username

    # using printf to hide the typing of the password
    printf "Password: "
    read -s password
    printf "\n"

else
    # reading username and password to be used from user, the password will be hidden while typing
    # creating empty file to store input text

    uname_result="input.txt"
    >$uname_result
    #creating dialogue box for input
    dialog --title "" \
    --backtitle "### NITC FIREWALL AUTHENTICATION ###" \
    --inputbox "Enter your username" 8 60 2>$uname_result

    # get the return value  
    response=$?
    username=$(<$uname_result)
    case $response in
    0) 
        data=$(tempfile 2>/dev/null)
        # delete the password stored file, if program is exited pre-maturely.
        trap "rm -f $data"
        dialog --title "Password" \
        --insecure \
        --clear \
        --passwordbox "Please enter password" 10 30 2> $data

        reply=$?

        case $reply in
        0) password=$(cat $data);;
        1) echo "You have pressed Cancel";;
        255) [ -s $data ] &&  cat $data || echo "ESC pressed.";;
        esac
    ;;
    1) echo "Cancelled." ;;
    255) echo "Escape key pressed."
    esac
    rm $uname_result


fi
##############################################################################################################

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
           then set self.triggered = false     


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
