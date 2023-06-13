import 'package:bonfire/bonfire.dart';

abstract class GameMap extends GameComponent {
  List<TileModel> tiles;
  double tileSizeToUpdate;
  double tileSize = 0.0;

  GameMap(this.tiles, {this.tileSizeToUpdate = 0}) {
    paint.isAntiAlias = false;
  }

  Iterable<Tile> getRendered();

  Future<void> updateTiles(List<TileModel> map);

  Vector2 getMapPosition();
  Vector2 getMapSize();

  Rect getMapRect() {
    return Rect.fromLTWH(
      getMapPosition().x,
      getMapPosition().y,
      getMapSize().x,
      getMapSize().y,
    );
  }

  void removeTile(String id);
  Future addTile(TileModel tileModel);

  @override
  int get priority => LayerPriority.MAP;

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    for (Tile t in getRendered()) {
      t.renderDebugMode(canvas);
    }
  }

  @override
  bool get isVisible => true;
}
