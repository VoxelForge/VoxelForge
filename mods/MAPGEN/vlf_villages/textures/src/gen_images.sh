tiles=(
	'../../../ITEMS/vlf_wool/textures/wool_white.png'
	'../../../ITEMS/vlf_wool/textures/wool_pink.png'
	'../../../ITEMS/vlf_wool/textures/wool_red.png'
	'../../../ITEMS/vlf_wool/textures/wool_black.png'
	'../../../ITEMS/vlf_wool/textures/wool_brown.png'
	'../../../ITEMS/vlf_wool/textures/wool_grey.png'
	'../../../ITEMS/vlf_wool/textures/vlf_wool_light_blue.png'
	'../../../ITEMS/vlf_wool/textures/vlf_wool_lime.png'
)

for  (( i = 1; i <= ${#tiles[@]}; i++ )); do
    tile=${tiles[$i - 1]}
	composite ../../../ITEMS/vlf_farming/textures/vlf_farming_wheat_stage_7.png ${tile} grain_${i}.png;
	composite ../../../ITEMS/vlf_farming/textures/farming_carrot.png ${tile} root_${i}.png;
	composite src/farming_pumpkin_side_small.png  ${tile} gourd_${i}.png;
	composite ../../../ITEMS/vlf_farming/textures/vlf_farming_sweet_berry_bush_0.png  ${tile} bush_${i}.png;
	composite ../../../ITEMS/vlf_flowers/textures/flowers_tulip.png  ${tile} flower_${i}.png;
	composite ../../../ITEMS/vlf_core/textures/default_sapling.png  ${tile} tree_${i}.png;
done
