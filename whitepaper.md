# Doichain
## a spam protection system storing email permissions inside the blockchain

==

Nico Krause (nico@doichain.org) www.doichain.org Firenze, 21.04.2018

**Abstract.** We propose a decentralized peer-to-peer system that allows entities to securely request and store a proven permission to send an email to another entity on a blockchain.

1. Introduction
```
The medium email works perfectly fine in principle, as long as we are
talking about private emails, which get sent to a single person or a small
group. However emails are being used for marketing- and selling campaigns
since the 1990s. These campaigns get more successful, the more people
receive your emails. Hence the large temptation to send as much emails as
possible, even if you can’t prove without a doubt, whether the address owner
did agree to receive this email or not. This circumstance and the
relatively cheap price to send emails, encouraged a flood of
huge numbers of emails.

Therefore a law was developed, to only allow mass sendings of emails if the
receiver gives permission to do so. This permission is usually granted with
a Double-Opt-In procedure, in other words, a granted permission for
advertising needs to be confirmed additionally. However the problem is,
that the independent third party, such as email providers or private smtp servers,
can’t verify this permission by newest data protection regulations. Both provider of the mail server and the receiver of the advertisement need to trust them, to manage the
declarations of consent and to reliably document a removal of an agreement.

SPAM is a consequence of violating this rule, and is perceived as
an unwanted interference by most people. Thus different methods got
developed to fend off SPAM. But to this day no system is reliable and
practical enough to differentiate between wanted and unwanted emails.
Sometimes it occurs, that desired emails land in the SPAM directory or
doesn’t arrive at all. On the other hand SPAM reaches the inbox of
the receiver. With Doichain this problem can be solved reliably,
while taking into account all data security regulations.
```
2. Affected parties
   - **Owner of an email address**

      *Goal:*
      - Declarations of consent can be managed and checked all the time.
      - Withdrawing an agreement needs to be documented and executed reliably.

      *Risk so far:* Unsubscribing a newsletter leads you to getting tagged as active, thus being a valuable email address to sell.

      *Consequence so far:* Even more email spam.

    - **Email service provider**

       *Goal:* Smooth delivery of emails.

       *Risk so far:* Damage to reputation because of address lists that are filled with SPAM-traps.

    - **Advertiser**

       *Goal:* Proper DOI-confirmed declarations of consent in order to send advertising mails.

       *Risk so far:* The lead-generator delivers missing or incorrect DOI-declarations of consent.

       *Consequence so far:* SPAM-traps are delivered into the database, which does significantly damage the reputation and complicates e-mail marketing or even renders it impossible.


    - **Mail Server provider and internet service provider** like hotmail, gmail, gmx etc. who let customers freely use their mailbox.

       *Goal:* Ensuring that valid e-mails are delivered into the inbox, while spam mails are sorted in the spam directory or blocked completely, all in the interest to satisfy their customers.

       *Risk so far:* Desired and awaited emails from customers are blocked and not delivered.


    - **Address generators** e.g. firms that specialise into mail campaigns in order to get agreements and addresses for their sponsors, who will use them in email marketing campaigns.

       *Goal:* Generate the highest number of permissions possible with a relatively low amount of capital, for sponsors to use in their advertising campaigns.


    - **Courts**
        *Goal:* Definite prove, if a permission was granted for the delivery of this e-mail at an exact point in time.*

3. General Workflow Proposal

4. dApp roles
5. Spam
6. Conclusion

References