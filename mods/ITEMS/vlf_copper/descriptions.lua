local lit_desc = "(Lit)"
local pow_desc = "(Powered)"
local mix_desc = "(Lit and Powered)"

vlf_copper.copper_descs = {
    ["copper"] = {
        "Block of Copper", "Waxed Block of Copper",
        "Exposed Copper", "Waxed Exposed Copper",
        "Weathered Copper", "Waxed Weathered Copper",
        "Oxidized Copper", "Waxed Oxidized Copper"
    },
    ["cut_copper"] = {
        "Cut Copper", "Waxed Cut Copper",
        "Exposed Cut Copper", "Waxed Exposed Cut Copper",
        "Weathered Cut Copper", "Waxed Weathered Cut Copper",
        "Oxidized Cut Copper", "Waxed Oxidized Cut Copper"
    },
    ["copper_grate"] = {
        "Copper Grate", "Waxed Copper Grate",
        "Exposed Copper Grate", "Waxed Exposed Copper Grate",
        "Weathered Copper Grate", "Waxed Weathered Copper Grate",
        "Oxidized Copper Grate", "Waxed Oxidized Copper Grate"
    },
    ["chiseled_copper"] = {
        "Chiseled Copper", "Waxed Chiseled Copper",
        "Exposed Chiseled Copper", "Waxed Exposed Chiseled Copper",
        "Weathered Chiseled Copper", "Waxed Weathered Chiseled Copper",
        "Oxidized Chiseled Copper", "Waxed Oxidized Chiseled Copper"
    },
    ["copper_bulb"] = {
        "Copper Bulb", "Waxed Copper Bulb",
        "Exposed Copper Bulb", "Waxed Exposed Copper Bulb",
        "Weathered Copper Bulb", "Waxed Weathered Copper Bulb",
        "Oxidized Copper Bulb", "Waxed Oxidized Copper Bulb"
    },
    ["copper_bulb_lit"] = {
        {"Copper Bulb", lit_desc}, {"Waxed Copper Bulb", lit_desc},
        {"Exposed Copper Bulb", lit_desc}, {"Waxed Exposed Copper Bulb", lit_desc},
        {"Weathered Copper Bulb", lit_desc}, {"Waxed Weathered Copper Bulb", lit_desc},
        {"Oxidized Copper Bulb", lit_desc}, {"Waxed Oxidized Copper Bulb", lit_desc}
    },
    ["copper_bulb_powered"] = {
        {"Copper Bulb", pow_desc}, {"Waxed Copper Bulb", pow_desc},
        {"Exposed Copper Bulb", pow_desc}, {"Waxed Exposed Copper Bulb", pow_desc},
        {"Weathered Copper Bulb", pow_desc}, {"Waxed Weathered Copper Bulb", pow_desc},
        {"Oxidized Copper Bulb", pow_desc}, {"Waxed Oxidized Copper Bulb", pow_desc}
    },
    ["copper_bulb_lit_powered"] = {
        {"Copper Bulb", mix_desc}, {"Waxed Copper Bulb", mix_desc},
        {"Exposed Copper Bulb", mix_desc}, {"Waxed Exposed Copper Bulb", mix_desc},
        {"Weathered Copper Bulb", mix_desc}, {"Waxed Weathered Copper Bulb", mix_desc},
        {"Oxidized Copper Bulb", mix_desc}, {"Waxed Oxidized Copper Bulb", mix_desc}
    }
}

vlf_copper.copper_longdescs = {
    ["copper"] = {
        "A block of copper is mostly a decorative block.",
		"Exposed copper is a decorative block.",
		"Weathered copper is a decorative block.",
		"Oxidized copper is a decorative block."
    },
    ["cut_copper"] = {
        "Cut copper is a decorative block.",
		"Exposed cut copper is a decorative block.",
		"Weathered cut copper is a decorative block.",
		"Oxidized cut copper is a decorative block."
    },
    ["copper_grate"] = {
        "Copper grate is a decorative block.",
		"Exposed copper grate is a decorative block.",
		"Weathered copper grate is a decorative block.",
		"Oxidized copper grate is a decorative block."
    },
    ["chiseled_copper"] = {
        "Chiseled copper is a decorative block.",
        "Exposed chiseled copper is a decorative block.",
        "Weathered chiseled copper is a decorative block.",
        "Oxidized chiseled copper is a decorative block."
    },
    ["copper_bulb"] = {
        "Copper bulb is a decorative block and a light source when lited.",
        "Exposed copper bulb is a decorative block and a light source when lited.",
        "Weathered copper bulb is a decorative block and a light source when lited.",
        "Oxidized copper bulb is a decorative block and a light source when lited."
    },
    ["copper_bulb_lit"] = {
        "Copper bulb is a decorative block and a light source.",
        "Exposed copper bulb is a decorative block and a light source.",
        "Weathered copper bulb is a decorative block and a light source.",
        "Oxidized copper bulb is a decorative block and a light source."
    },
    ["copper_bulb_powered"] = {
        "Copper bulb is a decorative block and a light source when lited.",
        "Exposed copper bulb is a decorative block and a light source when lited.",
        "Weathered copper bulb is a decorative block and a light source when lited.",
        "Oxidized copper bulb is a decorative block and a light source when lited."
    },
    ["copper_bulb_lit_powered"] = {
        "Copper bulb is a decorative block and a light source.",
        "Exposed copper bulb is a decorative block and a light source.",
        "Weathered copper bulb is a decorative block and a light source.",
        "Oxidized copper bulb is a decorative block and a light source."
    }
}

vlf_copper.stairs_subnames = {
    ["cut_copper"] = {
        "copper_cut", "waxed_copper_cut",
        "copper_exposed_cut", "waxed_copper_exposed_cut",
        "copper_weathered_cut", "waxed_copper_weathered_cut",
        "copper_oxidized_cut", "waxed_copper_oxidized_cut"
    }
}

vlf_copper.stairs_descs = {
    ["copper_cut"] = {
        "Slab of Cut Copper", "Double Slab of Cut Copper", "Stairs of Cut Copper",
    },
    ["waxed_copper_cut"] = {
        "Waxed Slab of Cut Copper", "Waxed Double Slab of Cut Copper", "Waxed Stairs of Cut Copper",
    },
    ["copper_exposed_cut"] = {
        "Slab of Exposed Cut Copper", "Double Slab of Exposed Cut Copper", "Stairs of Exposed Cut Copper"
    },
    ["waxed_copper_exposed_cut"] = {
        "Waxed Slab of Exposed Cut Copper", "Waxed Double Slab of Exposed Cut Copper", "Waxed Stairs of Exposed Cut Copper"
    },
    ["copper_weathered_cut"] = {
        "Slab of Weathered Cut Copper", "Double Slab of Weathered Cut Copper", "Stairs of Weathered Cut Copper"
    },
    ["waxed_copper_weathered_cut"] = {
        "Waxed Slab of Weathered Cut Copper", "Waxed Double Slab of Weathered Cut Copper", "Waxed Stairs of Weathered Cut Copper"
    },
    ["copper_oxidized_cut"] = {
        "Slab of Oxidized Cut Copper", "Double Slab of Oxidized Cut Copper", "Stairs of Oxidized Cut Copper"
    },
    ["waxed_copper_oxidized_cut"] = {
        "Waxed Slab of Oxidized Cut Copper", "Waxed Double Slab of Oxidized Cut Copper", "Waxed Stairs of Oxidized Cut Copper"
    }
}

vlf_copper.doors_descs = {
    {"Copper Door", "Copper Trapdoor"},
    {"Waxed Copper Door", "Waxed Copper Trapdoor"},
    {"Exposed Copper Door", "Exposed Copper Trapdoor"},
    {"Waxed Exposed Copper Door", "Waxed Exposed Copper Trapdoor"},
    {"Weathered Copper Door", "Weathered Copper Trapdoor"},
    {"Waxed Weathered Copper Door", "Waxed Weathered Copper Trapdoor"},
    {"Oxidized Copper Door", "Oxidized Copper Trapdoor"},
    {"Waxed Oxidized Copper Door", "Waxed Oxidized Copper Trapdoor"}
}
