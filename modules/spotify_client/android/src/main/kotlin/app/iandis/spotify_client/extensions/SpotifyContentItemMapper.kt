package app.iandis.spotify_client.extensions

import com.spotify.protocol.types.ImageUri
import com.spotify.protocol.types.ListItem
import com.spotify.protocol.types.ListItems

fun ListItems.toMap(): Map<String, Any?> {
    val itemsMap: MutableMap<String, Any?> = mutableMapOf()
    itemsMap["limit"] = this.limit
    itemsMap["offset"] = this.offset
    itemsMap["total"] = this.total
    itemsMap["items"] = this.items.map { it.toMap() }
    return itemsMap;
}

object ListItem {
    fun from(map: Map<String, Any?>): ListItem {
        return ListItem(
            map["id"] as String,
            map["uri"] as String,
            ImageUri(map["imageUri"] as String),
            map["title"] as String,
            map["subtitle"] as String,
            map["playable"] as Boolean,
            map["hasChildren"] as Boolean,
        )
    }
}

fun ListItem.toMap(): Map<String, Any?> {
    val itemMap: MutableMap<String, Any?> = mutableMapOf()
    itemMap["id"] = this.id
    itemMap["uri"] = this.uri
    itemMap["title"] = this.title
    itemMap["subtitle"] = this.subtitle
    itemMap["imageUri"] = this.imageUri.raw
    itemMap["playable"] = this.playable
    itemMap["hasChildren"] = this.hasChildren
    return itemMap
}