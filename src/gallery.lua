local gallery = {
  {
    id = 'beacon_1',
    name = 'Ignis Lucis',
    desc = 'Responds with light — the common language of the universe.',
    annot = {{{2}, {1}}},
  }, {
    id = 'stardust',
    name = 'Stardust',
    desc = 'Cosmic dust permeating every crevice of the vast space.',
    annot = {{{2}, {4, 4}}},
  }, {
    id = 'beacon_3',
    name = 'Ignis Noctis',
    desc = 'Nec lux sine nocte.\n[There is no light without darkness.]',
    annot = {{{2}, {3}}},
  }, {
    id = 'beacon_2',
    name = 'Ignis Mundi',
    desc = 'Where the tree of Yggdrasil grows.',
    annot = {{{2}, {2}}},
  }, {
    id = 'double_beacon',
    name = 'Ignis Duplex',
    desc = 'Repetition is the simplest way to counteract every type of interference.',
    annot = {{{2}, {1, 1}, 'typ. L'}, {{2}, {2, 2}, 'typ. M'}, {{2}, {3, 3}, 'typ. N'}},
  }, {
    id = 'echo',
    name = 'Canonis',
    desc = 'Sings every song that has been chanted.',
    annot = {{{1}, {1}}, {{2}, {2}}, {{3}, {3}}},
  }, {
    id = 'filter',
    name = 'Skia',
    desc = 'Mostly harmless.',
    annot = {{{2}, {2}, 'typ. M'}, {{1}, {4}}, {{3}, {4}}},
  }, {
    id = 'harmonia',
    name = 'Harmonia',
    desc = 'Where symmetry dwells, it spreads.',
    annot = {{{1}, {1, 3}}, {{3}, {3, 1}}, {{2}, {2, 2}}},
  }, {
    id = 'echo_dust',
    name = 'Nebularis',
    desc = 'Buried in the stardusts — or some delicious nectar?',
    annot = {{{1}, {1, 4}}, {{3}, {3, 4}}, {{2}, {2, 4}}},
  }, {
    id = 'condense',
    name = 'Plerosis',
    desc = 'Contraria sunt complementa.\n[Opposites are complementary.]',
    annot = {{{1, 1}, {1}}, {{1, 2}, {3}}, {{1, 3}, {2}}},
  }, {
    id = 'traverse',
    name = 'Triad',
    desc = 'A rotating lighthouse.',
    annot = {{{2}, {1}}, {{2}, {2}}, {{2}, {3}}},
  }, {
    id = 'palindrome',
    name = 'Ouroboros',
    desc = 'Falls apart once symmetry breaks. Just like the entire cosmos.',
    annot = {{{1, 2, 3}, {3, 2, 1}}--[[, {{1, 2, 3, 3}, {4, 4}}]]},
  }, {
    id = 'stickbug',
    name = 'Versipellis',
    desc = 'Somehow it appears familiar. Is it an illusion?',
    annot = {{{2}, {1}, nil, '< 5 s'}, {{2}, {3}, nil, '> 5 s'}},
  }, {
    id = 'pulsar',
    name = 'Pulsar',
    desc = 'Highly stable periodic emitter',
    annot = {{{}, {1}, '2 s'}, {{}, {1}, '2 s'}, {{2}, {}, '4 s'}},
  }, {
    id = 'long_double_echo',
    name = 'Galaxia',
    desc = 'A galaxy far, far away. Tries to devour everything, but something always scatters back.',
    annot = {{{2}, {2}, '4 s'}, {{}, {2}, '7 s'}},
  }, {
    id = 'fractus',
    name = 'Fractus',
    desc = 'Looks like it needs a hug.',
    annot = {},
  }, {
    id = 'vagus',
    name = 'Vagus',
    desc = 'A wandering traveller. Collects stardust on the way.',
    annot = {{{2}, {4}, '2 s'}, {{2, 2}, {4, 4}, '4 s'}, {{2, 2, 2}, {4, 4, 4}, '6 s'}},
  }, {
    id = 'blackhole',
    name = 'Blackhole',
    desc = 'Look not directly into it, for it sees through everything.',
    annot = {},
  },
}

for i = 1, #gallery do
  gallery[i].index = i
  gallery[gallery[i].id] = gallery[i]
end

return gallery
