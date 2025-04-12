local gallery = {
  {
    id = 'beacon_1',
    name = 'Ignis Lucis',
    desc = 'Responds with light — the common language of the universe.',
    annot = {{{2}, {1}}},
  }, {
    id = 'stardust',
    name = 'Stardust',
    desc = 'Cosmic dust permeating the space.',
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
    desc = 'A mirror',
    annot = {{{1}, {1}}, {{2}, {2}}, {{3}, {3}}},
  }, {
    id = 'filter',
    name = 'Skia',
    desc = 'A large tree covers most parts of it. Only certain signals can pass through.',
    annot = {{{2}, {2}, 'typ. M'}, {{1}, {4}}, {{3}, {4}}},
  }, {
    id = 'symmetry_pair',
    name = 'Harmonia',
    desc = 'The cosmos runs on symmetry.',
    annot = {{{1}, {1, 3}}, {{3}, {3, 1}}, {{2}, {2, 2}}},
  }, {
    id = 'echo_dust',
    name = 'Nebularis',
    desc = 'Buried in the stardusts',
    annot = {{{1}, {1, 4}}, {{3}, {3, 4}}, {{2}, {2, 4}}},
  }, {
    id = 'condense',
    name = 'Plerosis',
    desc = 'Maybe another definition of symmetry',
    annot = {{{1, 1}, {1}}, {{1, 2}, {3}}, {{1, 3}, {2}}},
  }, {
    id = 'traverse',
    name = 'Triad',
    desc = 'A rotating lighthouse',
    annot = {{{2}, {1}}, {{2}, {2}}, {{2}, {3}}},
  }, {
    id = 'palindrome',
    name = 'Ouroboros',
    desc = 'Duplex Ouroboros',
    annot = {{{1, 2, 3}, {3, 2, 1}}, {{1, 2, 3, 3}, {4, 4}}},
  }, {
    id = 'stickbug',
    name = 'Versipellis',
    desc = 'Masquerader',
    annot = {{{2}, {1}, nil, '< 5 s'}, {{2}, {3}, nil, '> 5 s'}},
  }, {
    id = 'pulsar',
    name = 'Pulsar',
    desc = 'Highly stable periodic emitter',
    annot = {{{}, {1}, '2 s'}, {{}, {1}, '2 s'}, {{2}, {}, '4 s'}},
  }, {
    id = 'long_double_echo',
    name = 'Galaxia',
    desc = 'A galaxy far, far away',
    annot = {{{2}, {2}, '4 s'}, {{}, {2}, '7 s'}},
  }, {
    id = 'fractus',
    name = 'Fractus',
    desc = '...',
    annot = {},
  }, {
    id = 'vagus',
    name = 'Vagus',
    desc = '...',
    annot = {},
  }, {
    id = 'blackhole',
    name = 'Blackhole',
    desc = '...',
    annot = {},
  },
}

for i = 1, #gallery do
  gallery[i].index = i
  gallery[gallery[i].id] = gallery[i]
end

return gallery
