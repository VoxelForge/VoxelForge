tiles=(
	'../../../CORE/vlf_textures/textures/block/PP/block/wool_white.png'
	'../../../CORE/vlf_textures/textures/block/PP/block/wool_pink.png'
	'../../../CORE/vlf_textures/textures/block/PP/block/wool_red.png'
	'../../../CORE/vlf_textures/textures/block/PP/block/wool_black.png'
	'../../../CORE/vlf_textures/textures/block/PP/block/wool_brown.png'
	'../../../CORE/vlf_textures/textures/block/PP/block/wool_grey.png'
	'../../../CORE/vlf_textures/textures/block/PP/block/vlf_wool_light_blue.png'
	'../../../CORE/vlf_textures/textures/block/PP/block/vlf_wool_lime.png'
)

for  (( i = 1; i <= ${#tiles[@]}; i++ )); do
    tile=${tiles[$i - 1]}
	composite ../../../CORE/vlf_textures/textures/block/PP/block/vlf_farming_wheat_stage_7.png ${tile} grain_${i}.png;
	composite ../../../CORE/vlf_textures/textures/block/PP/block/farming_carrot.png ${tile} root_${i}.png;
	composite src/farming_pumpkin_side_small.png  ${tile} gourd_${i}.png;
	composite ../../../CORE/vlf_textures/textures/block/PP/block/vlf_farming_sweet_berry_bush_0.png  ${tile} bush_${i}.png;
	composite ../../../CORE/vlf_textures/textures/block/PP/block/flowers_tulip.png  ${tile} flower_${i}.png;
	composite ../../../CORE/vlf_textures/textures/block/PP/block/default_sapling.png  ${tile} tree_${i}.png;
done
