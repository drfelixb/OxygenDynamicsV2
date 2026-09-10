import unittest
import numpy as np
from verify_surge_full_movie import recipe


class FullMovieRecipeTests(unittest.TestCase):
    def test_control_only_placement_and_waveforms(self):
        centers,f=recipe(128,128,600,4.75,np.ones((128,128)))
        self.assertTrue(np.array_equal(centers,[[64,64],[82,64]]))
        self.assertEqual(np.flatnonzero(f[0])[0]+1,101)
        self.assertEqual(np.flatnonzero(f[1])[-1]+1,384)
        self.assertAlmostEqual(max(f[0]),.2);self.assertAlmostEqual(min(f[5]),-.2)

    def test_no_eligible_position(self):
        with self.assertRaises(ValueError):recipe(128,128,600,4.75,np.zeros((128,128)))

    def test_overlapping_signs_sum_without_cross_term(self):
        _,f=recipe(128,128,600,4.75)
        self.assertGreater(max(f[2]+f[3]),.2)
        self.assertTrue(np.all(1+f.sum(axis=0)>0))
        self.assertTrue(np.all(f[0,:100]==0))


if __name__=='__main__':unittest.main()
