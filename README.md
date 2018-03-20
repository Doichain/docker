#doichain/docker
##a docker image for the Doichain environment http://www.doichain.org

### How to use this docker conainer?
1. if you want to register one or more "double-opt-in" for your email adresses install a SEND_DAPP
2. if you want to protect your email server from unwanted spam install CONFIRM_DAPP and VERIFY_APP (experimental)

### Build from doichain/docker GitHub repository 
1. Checkout this repository with: ``git clone https://github.com/Doichain/docker.git docker-doichain``
2. Build docker container with ``cd docker-doichain; docker build -t mydocker/doichain:latest .``

### Installation Send - dApp 
1. Install ``docker run -it --rm -e DAPP_SEND='true' -e CONNECTION_NODE='5.9.154.226' -p 3000:3000  mydocker/doichain:latest``
2. Get auth token with: ``curl -H "Content-Type: application/json" -X POST -d '{"username":"admin","password":"password"}' http://localhost:3000/api/v1/login``

    Output should be something like:

    ```
    {
      "status": "success",
      "data": {
        "authToken": "Y1z8vzJMo1qqLjr1pxZV8m0vKESSUxmRvbEBLAe8FV3",
        "userId": "a7Rzs7KdNmGwj64Eq"
    }
    ``

3. DOI-Request  
Take the **authToken** and **userId** from above and past it into the appropriate header fields below. 

```
curl -H "X-Auth-Token: Y1z8vzJMo1qqLjr1pxZV8m0vKESSUxmRvbEBLAe8FV3" -H "X-User-Id: a7Rzs7KdNmGwj64Eq" -H "Content-Type: application/json" -X POST --data "recipient_mail=nico@le-space.d&sender_mail=info@doichain.org" http://localhost:3000/api/v1/opt-in
```

### Installation Confirm - dApp - Build from doichain/docker GitHub repository 
docker run -it --rm -e DAPP_CONFIRM='true' -e DAPP_VERIFY='true' -e DAPP_SEND='true' -e CONNECTION_NODE='5.9.154.226' -e DAPP_SMTP_HOST=localhost -e DAPP_SMTP_USER=nico@nicokrause.com -e DAPP_SMTP_PASS=omnamahshivaya2017! -e DAPP_SMTP_PORT=25 -p 3000:3007 inspiraluna/doichain:0.0.2


