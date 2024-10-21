package systems.views;

import h2d.domkit.*;

class StoreView extends h2d.Flow implements h2d.domkit.Object {

    static var SRC = 
        <store-view class="box" layout="horizontal" id="topLevelView">
            
        </store-view>
        

    public function new(?parent) {
        super(parent);
        initComponent();
        
        var item1 = new ShopItemComponent("test",-1);
        topLevelView.addChild(item1);
        var item2 = new ShopItemComponent("test2",0);
        topLevelView.addChild(item2);
        var item3 = new ShopItemComponent("test3",5);
        topLevelView.addChild(item3);
        
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
            </shop-item>
    
    public function new(itemName:String,item_price:Int,?parent){
        super(parent);
        initComponent();
        var style = new h2d.domkit.Style();
        style.load(hxd.Res.style); 
        style.addObject(this);
        style.allowInspect = true;
        itemNameText.text=itemName;
        itemPriceText.text = '$item_price minion';
    }
}