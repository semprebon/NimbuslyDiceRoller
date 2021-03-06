window.testing_base_url = (test) ->
    window.location.protocol + "//" + window.location.host + test

url = window.location.protocol + "//" + window.location.host + "/test_storage/dice"

class TestItemClass
    constructor: (hash) ->
        for own key, value of hash
            this[key] = value
    
    toAttributes: -> { name: @name, content: @content }
    
    uppercaseName: -> @name.toUpperCase()
    
TestItemClass.itemFromAttributes = (attributes) -> new this(attributes)
    
store = new window.CachedRESTStorage url, "name", TestItemClass

module "storage basics"

test "reset wiki should delete all articles", 1, ->
    store.reset()
    equals(store.size(), 0, "store should be empty")

test "retrieving an unknown item 'test'", 1, ->
     store.reset()
     stop(1000)
     store.get "test", (data) -> 
        equals(data, undefined, "should return undefined")
        start()

test "searching for item by name prefix", 3, ->
     store.reset()
     store.putLocal({ name: "item 1", content: "testing 1" })
     store.putLocal({ name: "bad item", content: "not good" })
     store.putLocal({ name: "item 2", content: "testing 2" })
     stop(1000)
     store.search "item", (items) ->
         equals(items.length, 2, "should find 2 matching items")
         equals(items[0].name, "item 1", "lower key item should be first")
         equals(items[1].name, "item 2", "higher key item should be last")
         start()

test "searching for item by property", 3, ->
    store.reset()
    store.putLocal({ name: "parent", content: "testing 1" })
    store.putLocal({ name: "child 1", content: "not good", parent_item: "parent" })
    store.putLocal({ name: "child 2", content: "testing 2", parent_item: "parent" })
    stop(1000)
    store.search ((a) -> a.parent_item == "parent"), (items) ->
        equals(items.length, 2, "should find 2 matching items")
        equals(items[0].name, "child 1", "lower key item should be first")
        equals(items[1].name, "child 2", "higher key item should be last")
        start()

test "storing and creating arbitrary classes", 2, ->
    store.reset()
    store.syncing(false)
    item = new TestItemClass({ name: "andrew", content: "testing"})
    stop()
    store.put item, ->
        store.get item.name, (item2) ->
            equals(item2.uppercaseName(), "ANDREW", "Should restore name")
            ok(item2 instanceof TestItemClass, "should be correct class")
            start()
    
module "storage syncing"

# ajax = (options) -> window.testAjax(url, options)
# 
# resetWiki = -> 
#     store.reset()
#     console.log("Store reset")
# 
# itemIsOnRemote = (item) ->
#     data = ajax({ url: "/" + item.name, dataType: "json" })
#     return item.content == data.content
# 
# test "Create item locally; then sync", 8, ->
#     resetWiki()
#     store.syncing(false)
#     stop()
#     console.log("Running local sync test")
#     equals(store.unsyncedItems().length, 0, "should be no items waiting to be synced on reset store")
#     testItem = new TestItemClass({ name: "localItem", content: "testing" })
#     store.put testItem, =>
#         equals(store.unsyncedItems().length, 1, "should be one item waiting to be synced")
#         equals(store.synced(testItem.name), false, "just created item should be unsynced")
#         store.get testItem.name, (data) -> 
#             equals(data.name, testItem.name, "Expect name to return unchanged")
#             equals(data.content, testItem.content, "Except content to return unchanged" )
#             store.sync =>
#                 ok(itemIsOnRemote(testItem), "new item should be on remote after sync")
#                 equals(store.unsyncedItems().length, 0, "should be no items waiting to be synced")
#                 ok(store.synced(testItem.name), "just put item should be synced")
#                 start()
# 
# test "Create item remotely; then sync", 3, ->
#     resetWiki()
#     store.syncing(false)
#     testItem = { name: "remoteItem", content: "testing" }
#     ajax({ type: 'PUT', url: '/' + testItem.name, data: testItem })
#     stop()
#     store.sync =>
#         data = store.getLocal(testItem.name)
#         equals(data.content, testItem.content, "synced item should be same as on remote")
#         equals(store.unsyncedItems().length, 0, "should still be no items waiting to be synced")
#         ok(store.synced(testItem.name), "just synced item should be synced")
#         start()
# 
# test "Locally update existing synced item, then resync", 5, ->
#     resetWiki()
#     store.syncing(false)
#     testItem = { name: "existingItem", content: "before update" }
#     stop()
#     store.put testItem, =>
#         store.sync =>
#             testItem.content = "after update"
#             store.put testItem, =>
#                 equals(store.unsyncedItems().length, 1, "should be one item waiting to be synced")
#                 equals(store.synced(testItem.name), false, "just updated item should be unsynced")
#                 store.sync =>
#                     ok(itemIsOnRemote(testItem), "updated item should be on remote after sync")
#                     equals(store.unsyncedItems().length, 0, "should be no items waiting to be synced")
#                     ok(store.synced(testItem.name), "just updated item should be synced")
#                     start()
#                 
# test "remotely update existing synced item, then resync", 3, ->
#     resetWiki()
#     store.syncing(false)
#     testItem = { name: "existingItem", content: "before update" }
#     stop()
#     store.put testItem, =>
#         store.sync =>
#             testItem.content = "after update"
#             ajax({ type: 'PUT', url: '/' + testItem.name, data: testItem })
#             store.sync =>
#                 data = store.getLocal(testItem.name)
#                 equals(data.content, testItem.content, "synced item should be same as on remote")
#                 equals(store.unsyncedItems().length, 0, "should still be no items waiting to be synced")
#                 ok(store.synced(testItem.name), "just synced item should be synced")
#                 start()
# 
# test "locally delete existing synced item, then resync", 4, ->
#     resetWiki()
#     store.syncing(false)
#     testItem = { name: "existingItem", content: "before update" }
#     stop()
#     store.put testItem, =>
#         store.sync =>
#             store.delete(testItem.name)
#             equals(undefined, store.getLocal(testItem.name), "should not be able to get deleted item")
#             equals(store.synced(testItem.name), false, "deleted item should be waiting to be synced")
#             store.sync =>
#                 equals(store.synced(testItem.name), true, "deleted item should not be waiting to be synced")
#                 ajax { url: "/" + testItem.name, error: (xhr) =>
#                     equals(xhr.status, 404, "deleted item should be deleted from remote site")
#                 }
#                 start()
# 
# test "remotely delete existing synced item, then resync", 1, ->
#     resetWiki()
#     store.syncing(false)
#     testItem = { name: "existingItem", content: "before update" }
#     stop()
#     store.put testItem, =>
#         store.sync =>
#             ajax { url: "/" + testItem.name, type: 'DELETE' }
#             store.sync =>
#                 equals(store.getLocal(testItem.name, undefined, "Local item should be deleted"))
#                 start()

#         
# test "deleting an item should remote it", 1, ->
#     resetWiki()
#     stop(1000)
#     store.put "item 1", { name: "item 1", content: "testing 1" }, ->
#         store.delete "item 1", ->
#             equals(store.size(), 0, "store should be empty")
#             start()
#             
# test "sync should add remote items added since last update", 2, ->
#     resetWiki()
#     ajax({ url: "/new_item", type: 'PUT', data: { name: "new_item", content: "testing" } })
#     stop(2000)
#     store.sync -> 
#         console.log("now synced")
#         store.get "new_item", (data) -> 
#             console.log "got item"
#             equals(data.name, "new_item")
#             equals(data.content, "testing")
#             start()
# 
# test "sync should send to remote any items created local since last version", 1, ->
#     resetWiki()
#     stop(2000)
#     store.putLocal("item", { name: "item", content: "test item" })
#     store.sync ->
#         data = ajax({ url: "/item", dataType: "json" })
#         equals(data.name, "item")
#         start()
#         