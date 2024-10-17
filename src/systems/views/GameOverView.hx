package systems.views;

import h2d.domkit.*;

class GameOverView extends h2d.Flow implements h2d.domkit.Object {

    static var SRC = 
        <game-over-view class="box" layout="vertical">
            <text text={"Game Over!"}/>
            <text id="scoreText" text={""}/>
            <text text={"Press '3' to restart"}/>
        </game-over-view>
        

    public function new(score:Float=0,?parent) {
        super(parent);
        initComponent();
        var style = new h2d.domkit.Style();
        style.load(hxd.Res.style); 
        style.addObject(this);
        scoreText.text = 'Army size: $score';
    }
}