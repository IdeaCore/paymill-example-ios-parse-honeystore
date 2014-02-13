# Recurrent Billing with PAYMILL

PAYMILL is a full-stack payment solution with very reasonable pricing and is easy to setup. See how to add it to a iOS application here, for back end we use PARSE. If you want to use it only in iOS application you can look at VoucherMill(https://github.com/paymill/paymill-ios/tree/master/samples/vouchermill)

If you ever need to process credit card payments or recurring payments aka. subscriptions through your iOS applications, you should take a look at PAYMILL. 
PAYMILL is a payment gateway that is easy to set up and which is very developer friendly. It only charges fees on a per-transaction basis and these are very reasonable. 
There are no monthly fees or other hidden costs.

### What does the application

In this tutorial we’ll use PAYMILL to add payments to a iOS application, to store client ID instead of local database we use PARSE.
The application, which we’ll use is a simple store that sells Honey ;) 
The customer can add a jar with honey to his Cart and them make checkout for his order by PAYMILL. As we mention before we use PARSE as storage. We store products for sale there, registered users and PAYMILL client Id.
In this application we combinate different SDKs of PAYMILL. For public part we use PAYMILL's iOS SDK and for private use JS SDK. For easy scan of credit card we use CardIo.    

Before you use the app you must register as merchant in PAYMILL website and get your public and private key. Private key you must set in PARSE part, but public key must be used in iOS part.
![landing page](./docs-assets/01.pages_index.png)

There are four different products that user can buy and add it to the Cart. When the user select on one of the product, he will be redirected to the details page, there he can read about his choice and it to the Cart. 

![sign up page](./docs-assets/02.users_init.png)

For users management we user PARSE SDK. When you lunch the application you will see PARSE's SignUp and Logins screen. 
After the user register himself in the application, credentials are send to PARSE and then we use PAYMILL's JS SDK to create client Id. By this Id we make all transaction to PAYMILL. 


### Application internals

**Dependencies management**
Lets start at the beginning. 
As every application developer you don't want to write everything on your own. 
Nowadays for each programming language there are a lot of tools and frameworks, which we can use to speed up the development process and make our lives easier.

For dependancies management *Honey Store* uses very popular dependency manager: **CocoaPods**:
* [CardIo](https://github.com/card-io/card.io-iOS-SDK) - for easy scanning credit card.
* [PARSE](https://parse.com/) - we use PARSE as backend
* [paymill](https://github.com/paymill/paymill-ios) - iOs library, which simplifies development against PAYMILL API and hides communication infrastructure.

Before you start you must install **CocoaPods**, please read you to install it on http://cocoapods.org/.

After successful installation locate  *Honey Store* pod file and run in your terminal:  
```ios 
pod install 
``` 

As you can see **CocoaPods** prepare your project file and download all dependancy SDK.


**Application routing**


**Database**

**Models**

**Controllers**

**Dealing with clients**

**Adding PAYMILL’s JavaScript and The API Key**


**Handling the credit cards**

**Dealing with payments**

