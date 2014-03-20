# chantbox.io

Chantbox is an open source chat room web application for persistent or temporary conversations

Visit and use it on http://chantbox.io

Join the #chantbox channel on http://chantbox.io/r/chantbox

### Stack

* Chantbox is a realtime, Socket.io Node.js application
* written in Coffee-script, Stylus and Jade
* over the wonderful [Compound.js](http://compoundjs.com) framework
* with MongoDB as a persistent data-store
* and Angular.js on the front-end

### What of it

Chantbox is an exercise in socket.io, however it could be found useful for a lot of scenarios, like

* instant, no-sign up chats
* meetup chats
* classroom chats
* professional groups
* private messaging
* and more...

### Contributions

There's a lot more to be done, from the top of my head I can think of

* a responsive design is severely missing
* better room management and moderation (permissions, invites, etc)
* email notifications, digests on rooms of interest
* file sharing 
* a lot more tests (mostly on the front-end)
* and more

Feel free to fork and issue pull requests,
also feel free to contact me for more information on collaboration

### Run server

make sure mongod is running in the background and 
```
make server
```

### Test

```
make test
```

### License

GPL v2