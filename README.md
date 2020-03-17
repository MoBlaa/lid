# lid

Decentralized Identity and Security provider. The name actually is a combination of the words *local* (referencing the decentralized nature) and *id* (for identity) but turned out to be a nice metaphor.
This project aims to show people how to handle accounts and identities on the internet. This topic is very complex but why not try to improve it?

## Goals

1. Apps should be able to login using this app instead of some online third-party identity provider.
2. Manage identities of other platforms. This identities can be ued to prove to others that you are who you say you are.
3. Manage an identity book of other lid-accounts as well as their connected accounts.

As decentralization is the main goal of this application there are several problems which 
are already included in centralized architectures.

1. What's happening if I loose my phone?
    If the app is only installed on your phone you will not be able to restore your actual identity created with the previous smartphone. To have some kind of backup a system  to **connect multiple devices** which share the ownership of the same identity has to be created. Lets call this ownership system a **Lid**. The Lid is closed for all external access by default. By adding a device to the Lid you can open it and prove to be part of this identity.
2. How can i prove my Identity? How can others prove my identity?
    So lets play that through. You meet someone on facebook. You write some messages. So the **first level** of identification is reached "you know the owner of the account". So after some time you decide to make a video call. You can now approve the **second level** of identification which says "you approve the visual identity of the person is who the platform says". There is now only one level left. So lets say you two had contact for multiple days, weeks, months or whatever and decide to meat each other **in the real world**. As soon as you two meet you can approve or disprove the identity of the other one and successfully reach the **third level** of identification which says "you can approve the real identity of the person".
    This is what should be mirrored in the usage of the app. It doesn't only handle your identity it also handles **different levels of identification** you guarantee for another people and their accounts. This has to be revocable at any time.
    This mechanism is important in a decentralized identity provider. You should be able to **see who approves your identity and your ownership of different accounts** in order to trust them. This mechanism is ensured in centralized applications through the platform itself. But platforms like facebook only guarantee your ownership and real identity to mechanism like passwords and two-factor-authentication. We want to improve that.

### How to meet these goals

So what does the application actually have to do:

1. Create an identity to own.
2. Add accounts of other platforms to this identity.
3. Approve the different levels for people you communicate with. First level should be ready to approve after some conversation. Second level should be able to approve after video calls (an additional level could be able for audio calls). The third level of approval is available through some handshake made with your devices when meeting personally.

### Additional Ideas

- Invite/share others on different platforms to the app. This should add them to your identity book. This should contain information about **what accounts they own, whos identity they approve and who's not as well as which level of approval**.
- Secure communication over this identity. So not only provide an identity mechanism also provide (end-to-end) encrypted communication.
    The communication as well as the identification could be split into levels. Different levels of identification allow different security levels in communication. So if you haven't met personally your communication will be secured through some kind of diffie-hellmann handshake which will be kind of secure as the handshake will be performed through an insecure line. As soon as you meet personally another handshake could be performed which can be seen as more secure as you performed this handshake over higher secured line. (Exchanged secret shouldn't be used to encrypt actual messages but to derive new keys for encryption)
    
## Roadmap

- [v0.1.0]: Identity creation, add other devices to your lid.
- [v0.2.0]: Identity book - personal handshake with other User to add him to your identity book.
- [v0.3.0]: Callable from other apps to: Get Identity of the user, add others to the identity book, get approval level for other user.
- [v0.4.0]: External accounts - add accounts of different platforms to your identity and share them with others.