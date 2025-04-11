local gallery = {
  {
    id = 'beacon_1',
    name = 'Beacon of Light',
    desc = 'The common language of the universe.',
    annot = {{{2}, {1}}},
  }, {
    id = 'stardust',
    name = 'Stardust',
    desc = 'Cosmic dust permeating the space.',
    annot = {{{2}, {4, 4}}},
  }, {
    id = 'beacon_3',
    name = 'Beacon of Night',
    desc = 'Nec lux sine nocte.',
    annot = {{{2}, {3}}},
  }, {
    id = 'beacon_2',
    name = 'Beacon of Worlds',
    desc = 'Where Yggdrasil grows.',
    annot = {{{2}, {2}}},
  }, {
    id = 'double_beacon',
    name = 'Double Beacon',
    desc = 'Repetition is the simplest way to counteract every type of interference',
    annot = {{{2}, {1, 1}, 'typ. L'}, {{2}, {2, 2}, 'typ. M'}, {{2}, {3, 3}, 'typ. N'}},
  }, {
    id = 'echo',
    name = 'echo',
    desc = 'A mirror',
    annot = {{{1}, {1}}, {{2}, {2}}, {{3}, {3}}},
  }, {
    id = 'filter',
    name = 'filter',
    desc = 'A large tree covers most parts so only some signals can pass through',
    annot = {{{2}, {2}}, {{1}, {4}}, {{3}, {4}}},
  }, {
    id = 'symmetry_pair',
    name = 'symmetry_pair',
    desc = 'The answer to the cosmos is symmetry',
    annot = {{{1}, {1, 3}}, {{3}, {3, 1}}, {{2}, {2, 2}}},
  }, {
    id = 'echo_dust',
    name = 'echo_dust',
    desc = 'Buried in the stardusts',
    annot = {{{1}, {1, 4}}, {{3}, {3, 4}}, {{2}, {2, 4}}},
  }, {
    id = 'condense',
    name = 'condense',
    desc = 'Maybe another definition of symmetry',
    annot = {{{1, 1}, {1}}, {{1, 2}, {3}}, {{1, 3}, {2}}},
  }, {
    id = 'traverse',
    name = 'traverse',
    desc = 'A rotating lighthouse',
    annot = {{{2}, {1}}, {{2}, {2}}, {{2}, {3}}},
  }, {
    id = 'palindrome',
    name = 'palindrome',
    desc = 'Duplex Ouroboros',
    annot = {{{1, 2, 3}, {3, 2, 1}}},
  }, {
    id = 'stickbug',
    name = 'stickbug',
    desc = 'Masquerader',
    annot = {{{1}, {1}, nil, '< 5 s'}, {{1}, {3}, nil, '> 5 s'}},
  }, {
    id = 'pulsar',
    name = 'Pulsar',
    desc = 'Highly stable periodic emitter',
    annot = {{{}, {1}, '2 s'}, {{}, {1}, '2 s'}, {{2}, {}, '4 s'}},
  }, {
    id = 'long_double_echo',
    name = 'long_double_echo',
    desc = 'A galaxy far, far away',
    annot = {{{2}, {2}, '4 s'}, {{}, {2}, '7 s'}},
  },
}

for i = 1, #gallery do
  gallery[i].index = i
  gallery[gallery[i].id] = gallery[i]
end

return gallery
