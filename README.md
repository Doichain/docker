#doichain/docker
##a docker image for the Doichain environment http://www.doichain.org

### How to use this docker conainer?
1. if you want to register one or more "double-opt-in" for your email adresses install a SEND_DAPP
2. if you want to protect your email server from unwanted spam install CONFIRM_DAPP and VERIFY_APP (experimental)

### Build from doichain/docker GitHub repository 
1. Checkout this repository with: ``git clone https://github.com/Doichain/docker.git docker-doichain``
2. Build docker container with ``cd docker-doichain; docker build -t mydocker/doichain:latest .``

### Install from docker hub https://hub.docker.com/r/doichain/dapp/
replace ``mydocker/doichain:latest``with ``doichain/dapp:latest``

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
    ```
2.1 Give your Send - dAPP some funding: (during alpha test, please send email to funding@doichain.org)

3. DOI-Request  
Take the **authToken** and **userId** from above and past it into the appropriate header fields below. 
```
curl -X POST -H 'X-User-Id: a7Rzs7KdNmGwj64Eq' -H 'X-Auth-Token: Y1z8vzJMo1qqLjr1pxZV8m0vKESSUxmRvbEBLAe8FV3' -i 'http://localhost:3000/api/v1/opt-in?recipient_mail=<your-customer-email@example.com>&sender_mail=info@doichain.org&customer_id=123'
```

    Output should be: 
    ```
      {
      "status": "success",
      "data": {
        "message": "Opt-In added. ID: SyXPehQz6utWnacRa"
      }
    ```

