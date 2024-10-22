package systems.views;

import h2d.domkit.*;
import game.PlayerItem;

class StoreView extends h2d.Flow implements h2d.domkit.Object {

    static var SRC = 
        <store-view class="box" layout="horizontal" id="topLevelView">
            
        </store-view>
        

    public function new(items:Array<PlayerItem>,?parent) {
        super(parent);
        initComponent();
        var spot = 1;
        if(items != null){
            for(item in items){
                var item = new ShopItemComponent(item.name,item.baseCost, spot);
                topLevelView.addChild(item);
                spot++;
            }
        }
        
        var style = new h2d.domkit.Style();
        style.load(hxd.Res.style); 
        style.addObject(this);
        style.allowInspect = true;
    }
}

@:uiComp("shop-item")
class ShopItemComponent extends h2d.Flow implements h2d.domkit.Object {
    static var SRC = 
            <shop-item class="itemCard" layout="vertical">
                <text id="itemNameText" text={""} color="black"/>
                <text id="itemPriceText" text={""} color="black"/>
                <text id="instructionText" text={""} color="black"/>
            </shop-item>
    
    public function new(itemName:String,item_price:Float,instructionSpot:Int,?parent){
        super(parent);
        initComponent();
        var style = new h2d.domkit.Style();
        style.load(hxd.Res.style); 
        style.addObject(this);
        style.allowInspect = true;
        itemNameText.text=itemName;
        instructionText.text = 'Press $instructionSpot to buy';
        itemPriceText.text = '$item_price minion';
    }
}