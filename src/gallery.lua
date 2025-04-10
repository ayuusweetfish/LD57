local gallery = {
  {
    id = 'beacon_1',
    desc = 'Beacon of the light',
  }, {
    id = 'stardust',
    desc = 'Stardust permeating the space',
  }, {
    id = 'beacon_2',
    desc = 'Beacon of the worlds',
  }, {
    id = 'beacon_3',
    desc = 'Beacon of the night',
  }, {
    id = 'double_beacon',
    desc = 'Repetition is the simplest way to counteract every type of interference',
  }, {
    id = 'echo',
    desc = 'A mirror',
  }, {
    id = 'filter',
    desc = 'A large tree covers many parts so only some signals can pass through',
  }, {
    id = 'symmetry_pair',
    desc = 'The answer to the cosmos is symmetry',
  }, {
    id = 'echo_dust',
    desc = 'Buried in the stardusts',
  }, {
    id = 'condense',
    desc = 'Maybe another definition of symmetry',
  }, {
    id = 'alternate',
    desc = 'A rotating lighthouse',
  }, {
    id = 'palindrome',
    desc = 'Duplex Ouroboros',
  }, {
    id = 'long_double_echo',
    desc = 'A galaxy far, far away',
  },
}

for i = 1, #gallery do
  gallery[gallery[i].id] = gallery[i]
end

return gallery
