package systems.views;

import h2d.domkit.*;

class MenuView extends h2d.Flow implements h2d.domkit.Object {

    static var SRC = 
        <menu-view class="box" layout="vertical">
            <text text={"Hello World!"}/>
            <text text={"Press '1' to start level'"}/>
        </menu-view>
        

    public function new(?parent) {
        super(parent);
        initComponent();
        var style = new h2d.domkit.Style();
        style.load(hxd.Res.style); 
        style.addObject(this);
    }
}