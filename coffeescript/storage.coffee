# The storage. All items are stored locally, and synced with the database as needed

# TODO: Storage should prefetch all relevent records it needs from server (i..e, since it last synced)
# TODO: Storage should detect when offline; and periodically check if online when offline
class CachedRESTStorage

    # item states
    CLEAN = 'clean'
    DIRTY = 'dirty'
    DELETED = 'deleted'

    # Create a new Cached RESTful storage object
    #
    # @param {string} url  base url for the backing web service
    # @param {string} keyField  field of stored items to use as a key field
    constructor: (url, keyField, klass) ->
        @url = url
        @keyField = keyField
        @klass = klass
        @log("cached rest storage created for #{@url}", "(no key)")
        $('#ajax_error').ajaxError((e, xhr, settings, exception) =>
            $(this).html(xhr.responseText)
        )

    # Get item from local storage
    #
    # @param {string} key  The key value for the item to get
    # @return item, or undefined if item not found or has been deleted
    getLocal: (key) ->
        @log("fetching local data", key)
        raw = localStorage[@urlFor(key)]
        return undefined if raw == undefined
        meta = JSON.parse(raw)
        return undefined if meta.state == DELETED
        return @itemFromAttributes(meta.data)
    
    # Get item from remote storage and put it into local storage
    #
    # @param {string} key
    # @param {function(item)} callback  function to call after item is fetched
    # @param {function(xhr,status)} errorCallback  function to call if an AJAX error occurs
    getRemote: (key, callback, errorCallback) ->
        @log('fetching remote data...', key)
        item = $.ajax { 
            url: @urlFor(key), 
            dataType: 'json',
            success: (item) => @putLocal(item); callback(item),
            error: (xhr, status) => errorCallback(xhr, status)
        }
        
    # Get item from local storage, after perhaps syncing with remote storage
    #
    # @param {string} key  The key value for the item to get
    # @param {function(item)} callback  function to call after item is fetched
    # @param {function(xhr,status)} errorCallback  function to call if an AJAX error occurs
    get: (key, callback, errorCallback) ->
        # optionall sync here if offline
        item = @getLocal(key)
        callback(item)

    # Puts or replaces an item in local storage, marking it for later remote updating
    #
    # @param {object} data  Item to store
    # @param {string} state  optional state to set on the object, used internaly  
    putLocal: (data, state) ->
        data = @attributesFromItem(data)
        state = DIRTY if state == undefined
        data_str = JSON.stringify({ 'state': state, 'data': data })
        localStorage[@urlFor(data)] = data_str

    # Puts or replaces an item on the remote server
    #
    # @param {object} data  Item to store
    # @param {function()} callback  function to call after item is put
    # @param {function(xhr,status)} errorCallback  function to call if an AJAX error occurs
    putRemote: (data, callback, errorCallback) ->
        data = @attributesFromItem(data)
        console.log("remote putting " + JSON.stringify(data))
        $.ajax { 
            type: 'PUT', url: @urlFor(data), data: data, 
            success: (data) => @log("remote data saved", data); callback(data) if callback,
            error: => @log("error", data); errorCallback() if errorCallback
        }
        
    # Puts or replaces an item, possibly also sending it to the remote server
    #
    # @param {object} data  Item to store
    # @param {function()} callback  function to call after item is put
    # @param {function(xhr,status)} errorCallback  function to call if an AJAX error occurs
    put: (data, callback, errorCallback) ->
        @putLocal(data)
        if @syncing()
            @log("storing remote data...", data)
            @putRemote(data, callback, errorCallback)
        else
            callback() if callback

    # Mark an item as deleted in local storage, and queue it to be deleted remotely
    markDelete: (keyOrItem) ->
        @log("deleting local data", keyOrItem)
        @state(keyOrItem, DELETED)

    deleteLocal: (name) ->
        localStorage.removeItem(@urlFor(name))

    deleteRemote: (name, callback) ->
        $.ajax {
            type: 'DELETE', url: @urlFor(name),
            success: => @log("remote data deleted", name); callback() if callback
        }
        
    delete: (keyOrItem, callback) ->
        @markDelete(keyOrItem)
    
    DEFAULT_CONFIG = { state: CLEAN, lastRemoteVersion: 0 }
    
    configureOption: (name, value) ->
        data = localStorage[@url] || DEFAULT_CONFIG
        if value
            data[name] = value
            localStorage[@url] = data
        return data[name]
        
    version: (newVersion) -> @configureOption('version', newVersion)
    
    syncing: (flag) -> @configureOption('syncing', flag)
         
    unsyncedItem: (name) ->
        switch @state(name)
            when DIRTY then @getLocal(name)
            when DELETED then name
            else nil
        
    unsyncedItems: ->
        items = (@unsyncedItem(name) for name in @allKeys())
        (item for item in items if item?)
        
    itemMetadata: (keyOrItem, metatag, value) ->
        url = @urlFor(keyOrItem)
        raw = localStorage[url]
        return undefined unless raw?
        meta = JSON.parse(raw)
        if value != undefined
            meta[metatag] = value
            localStorage[url] = JSON.stringify(meta)
        meta[metatag]

    state: (name, value) -> @itemMetadata(name, "state", value)
    
    synced: (name, value) -> 
        state = @state(name, value)
        state == CLEAN || state == undefined
        
    syncItem: (item, callback) ->
        if (typeof item) == "string"
            @deleteRemote item, =>
                @deleteLocal(item)
                callback()
        else
            @putRemote item, =>
                @state(item, CLEAN)
                callback()
        
    # Remove the first item in items and send it to remote; processing the remaining list
    # in the callback
    sendNextItem: (items, callback) ->
        if items.length == 0
            callback()
        else
            item = items.shift()
            @syncItem(item, => @sendNextItem(items, callback))
                        
    sendLocallyModifiedItems: (callback) ->
        items = @unsyncedItems()
        @sendNextItem(items, callback) 
        
    # TODO: save last sent remote version and use it when resending
    sync: (callback) ->
        @log("syncing remote data...", "")
        @sendLocallyModifiedItems =>
            @log("getting remote changes", "")
            $.ajax { type: 'GET', url: "#{@url}?since_version=0", dataType: "json", success: (items) =>
                @log("got #{items.length} items", "")
                for item in items
                    @log("syncing " + JSON.stringify(item))
                    if item.deleted
                        @deleteLocal(item)
                    else
                        @putLocal(item, CLEAN)
                @log("synced.", "")
                callback() if callback
            }

    # Return an array of all keys that start with the specified prefix
    keysWithPrefix: (keyPrefix) ->
        keys = []
        return keys if localStorage.length == 0
        urlPrefix = @urlFor(keyPrefix)
        for index in [0...localStorage.length]
            url = localStorage.key(index)
            keys[keys.length] = @keyForUrl(url) if url.substr(0, urlPrefix.length) == urlPrefix
        return keys
    
    searchLocal: (condition) ->
        if typeof condition == 'string'
            prefix = condition
            condition = (item) -> item.name.substr(0, prefix.length) == prefix
        (item for item in @allItems() when condition(item))
        
    search: (condition, callback) ->
        items = @searchLocal(condition)
        callback(items) if callback
        items
        
    attributesFromItem: (item) -> if item && item.toAttributes then item.toAttributes() else item
    
    itemFromAttributes: (attributes) ->
        return attributes unless @klass && attributes
        return attributes if (typeof(@klass) == "function") && attributes instanceof @klass
        if @klass.itemFromAttributes
            @klass.itemFromAttributes(attributes)
        else
            new @klass(attributes)
    
    allKeys: -> @keysWithPrefix("").sort()
    
    allItems2: (callback) -> 
        articles = []
        for key in @allKeys()
            item = @getLocal(key)
            articles.push(item) if item
        callback(articles) if callback
        articles

    allItems: (callback) -> 
        articles = (@getLocal(key) for key in @allKeys() when key?)
        callback(articles) if callback
        articles

    # Remove all local data for this store
    reset: -> 
        (@deleteLocal(key) for key in @allKeys())
        @version(0)
    
    size: -> @allKeys().length
        
    urlFor: (keyOrItem) -> "#{@url}/#{@keyFor(keyOrItem)}"
    
    keyFor: (keyOrItem) -> if (typeof keyOrItem) == "object" then keyOrItem[@keyField] else keyOrItem

    keyForUrl: (url) -> url.substr(@url.length + 1)

    log: (message, keyOrItem) ->
        console.info("#{message}:#{@keyFor(keyOrItem)}")

CachedRESTStorage.isAvailable = ->
    try
        return window['localStorage'] != undefined
    catch e
        return false;

window.CachedRESTStorage = CachedRESTStorage
