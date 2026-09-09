"""Arithmetic and corruption checks for the experimental separation verifier."""
import copy
import unittest
from verify_surge_separation import check_scores, require, weights


def fixture():
    mass = []
    for rid, values in ((1, (.8, .1)), (2, (.1, .7))):
        row = {'CandidateRunID': str(rid)}
        for k, v in enumerate(values, 1):
            row.update({f'Recipe{k}Mass': str(v*100), f'Recipe{k}Total': '100', f'Recipe{k}Coverage': str(v)})
        mass.append(row)
    scores = []
    for k, (cov, fraction, total) in enumerate(((.8, 8/9, .9), (.7, 7/8, .8)), 1):
        scores.append(dict(RecipeSource=str(k), AssignedCandidateRunID=str(k), RecipeMassCoverage=str(cov),
                           RecipeContributionFraction=str(fraction), AllRetainedRecipeMassCoverage=str(total),
                           RunsCoveringAtLeastTenPercent='2'))
    return mass, scores


class SeparationVerifierTests(unittest.TestCase):
    def test_valid(self):
        check_scores(*fixture(), 'approach_pair')

    def test_reused_run(self):
        m, s = fixture(); s[1]['AssignedCandidateRunID'] = '1'
        with self.assertRaises(ValueError):
            check_scores(m, s, 'approach_pair')

    def test_corrupt_coverage(self):
        m, s = fixture(); m[0]['Recipe1Coverage'] = '.9'
        with self.assertRaises(ValueError):
            check_scores(m, s, 'approach_pair')

    def test_nonfinite_mass(self):
        m, s = fixture(); m[0]['Recipe1Mass'] = 'NaN'
        with self.assertRaises(ValueError):
            check_scores(m, s, 'approach_pair')

    def test_duplicate_source(self):
        m, s = fixture(); s[1] = copy.deepcopy(s[0])
        with self.assertRaises(ValueError):
            check_scores(m, s, 'approach_pair')

    def test_suboptimal_assignment(self):
        m, s = fixture()
        for j, row in enumerate(s):
            a = 1-j
            row['AssignedCandidateRunID'] = str(a+1)
            row['RecipeMassCoverage'] = '.1'
            row['RecipeContributionFraction'] = str(10 / (80 if a else 90))
        with self.assertRaisesRegex(ValueError, 'optimal'):
            check_scores(m, s, 'approach_pair')

    def test_empty_retained_set(self):
        s = [dict(RecipeSource=str(k), AssignedCandidateRunID='NaN', RecipeMassCoverage='0',
                  RecipeContributionFraction='NaN', AllRetainedRecipeMassCoverage='0',
                  RunsCoveringAtLeastTenPercent='0') for k in (1, 2)]
        check_scores([], s, 'approach_pair')

    def test_checks_survive_optimization(self):
        with self.assertRaises(ValueError):
            require(False, 'Explicit failure')

    def test_recipe_excludes_outside_window(self):
        self.assertEqual(weights(512, 512, 100, 2.35, 'separate_pair').sum(), 0)
        self.assertEqual(weights(512, 512, 181, 2.35, 'single_expanding').sum(), 0)


if __name__ == '__main__':
    unittest.main()
