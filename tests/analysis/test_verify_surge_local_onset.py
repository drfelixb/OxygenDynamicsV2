import unittest
import numpy as np
from verify_surge_local_onset import estimate, same


class OnsetReferenceTests(unittest.TestCase):
    def setUp(self):
        self.t=np.arange(1,201);self.x=100+np.maximum(0,self.t-100);self.blocked=np.zeros(200,bool)

    def test_exact_ramp(self):
        r=estimate(self.x,120,150,self.blocked)
        self.assertEqual(r['OnsetFrame'],101);self.assertEqual(r['BaselineStartFrame'],81)
        self.assertAlmostEqual(r['ProvisionalAmplitude'],.5)

    def test_no_linear_onset(self):
        for x in (np.ones(200)*100,100+self.t):
            self.assertEqual(estimate(x,120,150,self.blocked)['Status'],'insufficient_improvement')

    def test_falling(self):
        self.assertEqual(estimate(200-np.maximum(0,self.t-100),120,150,self.blocked)['Status'],'not_a_rising_change')

    def test_neighbor_and_native_exclusions(self):
        self.blocked[74]=True
        self.assertEqual(estimate(self.x,120,150,self.blocked)['Status'],'overlapping_detection_in_fit')
        self.blocked[74]=False;self.blocked[119:150]=True
        self.assertEqual(estimate(self.x,120,150,self.blocked)['Status'],'resolved')

    def test_broad_profile_not_confident(self):
        x=100+.07*np.maximum(0,self.t-100)+np.random.default_rng(5).normal(0,1,200)
        r=estimate(x,120,150,self.blocked)
        self.assertEqual(r['Status'],'broad_profile_unresolved');self.assertTrue(np.isnan(r['OnsetFrame']))

    def test_search_edge_and_recording_edge(self):
        self.assertEqual(estimate(100+np.maximum(0,self.t-79),120,150,self.blocked)['Status'],'search_boundary_unresolved')
        self.assertEqual(estimate(self.x,40,60,self.blocked)['Status'],'recording_boundary_unresolved')

    def test_missing_native_signal_keeps_amplitude_missing(self):
        x=self.x.astype(float);x[139]=np.nan;r=estimate(x,120,150,self.blocked)
        self.assertEqual(r['Status'],'resolved');self.assertEqual(r['BaselineStatus'],'missing_native_signal')
        self.assertTrue(np.isnan(r['ProvisionalAmplitude']))

    def test_mismatch_fails_under_optimization(self):
        with self.assertRaises(ValueError):same('0.2',.3,'amplitude')


if __name__=='__main__':unittest.main()
