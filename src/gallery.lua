local gallery = {
  {
    id = 'beacon_1',
    name = 'Beacon of Light',
    desc = 'The common language of the universe.',
  }, {
    id = 'stardust',
    name = 'Stardust',
    desc = 'Cosmic dust permeating the space.',
  }, {
    id = 'beacon_3',
    name = 'Beacon of Night',
    desc = 'Nec lux sine nocte.',
  }, {
    id = 'beacon_2',
    name = 'Beacon of Worlds',
    desc = 'Where Yggdrasil grows.',
  }, {
    id = 'double_beacon',
    name = 'Double Beacon',
    desc = 'Repetition is the simplest way to counteract every type of interference',
  }, {
    id = 'echo',
    name = 'echo',
    desc = 'A mirror',
  }, {
    id = 'filter',
    name = 'filter',
    desc = 'A large tree covers most parts so only some signals can pass through',
  }, {
    id = 'symmetry_pair',
    name = 'symmetry_pair',
    desc = 'The answer to the cosmos is symmetry',
  }, {
    id = 'echo_dust',
    name = 'echo_dust',
    desc = 'Buried in the stardusts',
  }, {
    id = 'condense',
    name = 'condense',
    desc = 'Maybe another definition of symmetry',
  }, {
    id = 'traverse',
    name = 'traverse',
    desc = 'A rotating lighthouse',
  }, {
    id = 'palindrome',
    name = 'palindrome',
    desc = 'Duplex Ouroboros',
  }, {
    id = 'long_double_echo',
    name = 'long_double_echo',
    desc = 'A galaxy far, far away',
  },
}

for i = 1, #gallery do
  gallery[gallery[i].id] = gallery[i]
end

return gallery
