//
// Tessellate.js - https://github.com/davidgovea/tessellate - MIT License
//

(function(Raphael){
    Raphael.fn.grid = function(startx, starty, rows, cols, width, fill, roundR){
        var cellList = [],
            x = startx,
            y = starty,
            r = typeof roundR === 'number' ? roundR : 0;
    
        for (var i=0; i<rows; i++){
            cellList[i] = [];
            x = startx;
            for(var j=0; j<cols; j++){
                var cell = this.rect(x,y,width,width,r);
                cell.attr('fill', fill);
                cell.attr('stroke-width',0.5)
                cell.row = i;
                cell.col = j;
                cell.active = false;
                cell.occupied = false;
               // cell.click(cellClick);
                //cell.mouseover(cellOver);
                //cell.mouseout(cellOut);
                cellList[i][j] = cell;
                x += width;
            }
            y += width;
        }
    //    console.timeEnd('gridCreate');
        return cellList;
    }
    
    // Draws Octagon: clockwise path starting with top segment
    Raphael.fn.octagon = function(startx, starty, width){
        var rad2 = Math.SQRT2,
            side = width/(1+rad2),
            side_over_rad2 = side/rad2;
            p = this.path(
                "M"+(startx+side_over_rad2)+' '+(starty)+
                'l'+(side)+' '+(0)+
                'l'+(side_over_rad2)+' '+(side_over_rad2)+
                'l'+(0)+' '+(side)+
                'l'+(-side_over_rad2)+' '+(side_over_rad2)+
                'l'+(-side)+' '+(0)+
                'l'+(-side_over_rad2)+' '+(-side_over_rad2)+
                'l'+(0)+' '+(-side)+
                'l'+(side_over_rad2)+' '+(-side_over_rad2)+'z'
            );
        return p;
    }

    


    Raphael.fn.octogrid = function(startx,starty,rows,cols,width,fill){
        console.time('Create OctoGrid');
        var cellList = {},
            x = startx,
            y = starty,
            side = width/(1+Math.SQRT2);
    
        var getangle = function(x,y){
            var i       = 1,
                target  = 0,
                atan    = Math.atan(y/x)/(Math.PI/180),
                inc     = 22.5;
            if(x<0) {
                atan += 180;
            } else if(y<0) {
                atan += 360;
            }
       
            while(i*inc < atan){
                //console.log(i+" "+atan);
                target  += 1;
                i       += 2;
            }
            console.log(target);
            return (target > 7) ? target % 8 : target;
        };
        var horvert = {
            0: [1,0],
            2: [0,1],
            4: [-1, 0],
            6: [0,-1]
        };
        var diags = {
            1: [1, 1],
            3: [-1, 1],
            5: [-1, -1],
            7: [1, -1]
        };
        var start = function () {
        // storing original coordinates
                this.attr({opacity: 0.5});
            },
            move = function (dx, dy) {
    

                var target = getangle(dx, dy);
                var line;
                if((this.row === 1) && (target === 5 || target === 6 || target === 7)){
                    return false;
                } else if ((this.col === 1) && (target === 3 || target === 4 || target === 5)){
                    return false;
                } else if ((this.row === (rows-1)) && (target === 1 || target === 2 || target === 3)){
                    return false;
                } else if ((this.col === (cols-1)) && (target === 0 || target === 1 || target === 7)){
                    return false                    
                } else if (target === 0 || target === 2 || target === 4 || target === 6){
                    line = horvert[target];
                } else
                    line = diags[target];
                
                if (typeof this.dragLine !== 'undefined'){this.dragLine.remove();}
                this.dragLine = this.paper.path(
                "M"+(this.attrs.x+this.attrs.height/2)+' '+(this.attrs.y+this.attrs.height/2)+
                'l'+(line[0]* width)+' '+(line[1]*width)
                );
                this.dragLine.attr('stroke-width',5);
                
                //console.log(dx+","+dy);
                // move will be called with dx and dy
                //this.translate(dx-this.ddxy[0],dy-this.ddxy[1]);
                //this.ddxy=[dx,dy];
            },
            up = function (a) {
                console.log(a);
                // restoring state
                this.attr({opacity: 1});
            };

        for (var i=0; i<rows; i++){
         //   cellList[i] = [];
            x = startx;
            for(var j=0; j<cols; j++){
                var cell = this.octagon(x,y,width);
                cell.attr('fill', fill);
                //cell.attr('stroke-width',0.5)
                cell.row = i;
                cell.col = j;
                cell.active = false;
               // cell.click(cellClick);
                //cell.mouseover(cellOver);
                //cell.mouseout(cellOut);
                cellList[(i+1)+"_"+(j+1)+"_1"] = cell;
                //cellList[i][j] = cell;
    
                if(i>0 && j > 0){
                    var d = this.rect((x-side/2),(y-side/2),side,side);
                    d.rotate(45);
                    d.attr('fill','#3f3f3f');
                    d.row = i;
                    d.col = j;
                    cellList[i+"_"+j+"_2"] = d;
                  //  d.attr('stroke-width',0.5)
                    d.drag(move, start, up);
                }
    
                x += width;
            }
            y += width;
        }
        console.timeEnd('Create OctoGrid');
        return cellList;
    }

    
}(Raphael));